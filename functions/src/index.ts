import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";

admin.initializeApp();
const db = admin.firestore();

const correctAnswersV1 = [1, 2, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 2];

function gradeOf(percentage: number) {
  if (percentage >= 90) return { grade: 5, label: "Jeles", passed: true };
  if (percentage >= 80) return { grade: 4, label: "Jó", passed: true };
  if (percentage >= 60) return { grade: 3, label: "Közepes", passed: false };
  if (percentage >= 40) return { grade: 2, label: "Elégséges", passed: false };
  return { grade: 1, label: "Elégtelen", passed: false };
}

/** Official, server-side Academy evaluation. Client scores are never trusted. */
export const submitAcademyExam = onCall({ region: "europe-west3" }, async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Bejelentkezés szükséges.");
  const answers = request.data?.answers;
  if (!Array.isArray(answers) || answers.length !== correctAnswersV1.length ||
      !answers.every((value: unknown) => typeof value === "number" && Number.isInteger(value) && value >= 0 && value <= 2)) {
    throw new HttpsError("invalid-argument", "Érvényes, 20 válaszos vizsga szükséges.");
  }
  const correctCount = answers.reduce((sum: number, answer: number, index: number) =>
      sum + (answer === correctAnswersV1[index] ? 1 : 0), 0);
  const percentage = Math.round((correctCount / correctAnswersV1.length) * 100);
  const result = gradeOf(percentage);
  const attempt = db.collection("academy_exam_attempts").doc();
  await attempt.set({
    userId: request.auth.uid,
    answers,
    examVersion: 1,
    correctCount,
    percentage,
    ...result,
    source: "server_verified",
    completedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  if (result.passed) {
    await db.collection("users").doc(request.auth.uid).set({
      academyPassed: true,
      academyLatestPercentage: percentage,
      academyLatestGrade: result.grade,
      academyVerifiedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
  }
  return { attemptId: attempt.id, correctCount, percentage, ...result };
});

async function notifyUser(uid: string | undefined, title: string, body: string, data: Record<string, string>) {
  if (!uid) return;
  const user = await db.collection("users").doc(uid).get();
  const token = user.data()?.fcm_token as string | undefined;
  if (!token) return;
  try { await admin.messaging().send({ token, notification: { title, body }, data }); } catch (_) { /* expired token is harmless */ }
}

/** Sends push for shared marketplace state changes. */
export const notifyOrderChange = onDocumentWritten({ region: "europe-west3", document: "orders/{orderId}" }, async (event) => {
  const current = event.data?.after.data();
  if (!current) return;
  const previous = event.data?.before.data();
  if (previous?.status === current.status) return;
  const id = event.params.orderId;
  await Promise.all([
    notifyUser(current.customer_uid, "Munkád frissült", `${current.service ?? "Munka"}: ${current.status ?? "frissítés"}`, { orderId: id, role: "customer" }),
    notifyUser(current.provider_uid, "Munkád frissült", `${current.service ?? "Munka"}: ${current.status ?? "frissítés"}`, { orderId: id, role: "provider" }),
  ]);
});

/** Reveals overdue one-sided ratings without exposing the other party early. */
export const revealOverdueReviews = onSchedule({ region: "europe-west3", schedule: "every 60 minutes", timeZone: "Europe/Budapest" }, async () => {
  const cutoff = admin.firestore.Timestamp.fromDate(new Date(Date.now() - 72 * 60 * 60 * 1000));
  const snap = await db.collection("orders").where("completed_at_server", "<=", cutoff).where("reviews_visible", "==", false).get();
  const batch = db.batch();
  snap.docs.forEach((doc) => batch.update(doc.ref, { reviews_visible: true, reviews_revealed_at: admin.firestore.FieldValue.serverTimestamp() }));
  if (!snap.empty) await batch.commit();
});

/** Marks completion with Firebase server time.  This timestamp is the sole
 * source of truth for the 72-hour review window. */
export const completeOrder = onCall({ region: "europe-west3" }, async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Bejelentkezés szükséges.");
  const orderId = request.data?.orderId;
  if (typeof orderId !== "string" || !orderId.trim()) throw new HttpsError("invalid-argument", "Érvényes munkaazonosító szükséges.");
  const ref = db.collection("orders").doc(orderId);
  return db.runTransaction(async (tx) => {
    const order = await tx.get(ref);
    const data = order.data();
    if (!order.exists || !data) throw new HttpsError("not-found", "A munka nem található.");
    if (data.customer_uid !== request.auth!.uid && data.provider_uid !== request.auth!.uid) {
      throw new HttpsError("permission-denied", "Nincs jogosultságod ehhez a munkához.");
    }
    if (data.status === "Lemondva") throw new HttpsError("failed-precondition", "A lemondott munka nem teljesíthető.");
    if (data.status !== "Teljesítve") {
      tx.update(ref, {
        status: "Teljesítve",
        completed_at_server: admin.firestore.FieldValue.serverTimestamp(),
        reviews_visible: false,
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
    return { accepted: true };
  });
});

/** The phone cannot reveal, replace or submit an out-of-time review. */
export const submitOrderReview = onCall({ region: "europe-west3" }, async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Bejelentkezés szükséges.");
  const { orderId, rating } = request.data ?? {};
  const review = typeof request.data?.review === "string" ? request.data.review.trim().slice(0, 1000) : "";
  if (typeof orderId !== "string" || !Number.isInteger(rating) || rating < 1 || rating > 5) throw new HttpsError("invalid-argument", "Érvényes értékelés szükséges.");
  const ref = db.collection("orders").doc(orderId);
  return db.runTransaction(async (tx) => {
    const order = await tx.get(ref);
    const data = order.data();
    if (!order.exists || !data) throw new HttpsError("not-found", "A munka nem található.");
    const role = data.customer_uid === request.auth!.uid ? "customer" : data.provider_uid === request.auth!.uid ? "provider" : null;
    if (!role || data.status !== "Teljesítve") throw new HttpsError("permission-denied", "Ez a munka még nem értékelhető.");
    const completedAt = data.completed_at_server as admin.firestore.Timestamp | undefined;
    if (!completedAt || Date.now() > completedAt.toMillis() + 72 * 60 * 60 * 1000) throw new HttpsError("deadline-exceeded", "Lejárt az értékelési határidő.");
    const mine = ref.collection("reviews").doc(role);
    const other = ref.collection("reviews").doc(role === "customer" ? "provider" : "customer");
    const [existing, otherReview] = await Promise.all([tx.get(mine), tx.get(other)]);
    if (existing.exists) throw new HttpsError("already-exists", "Az értékelés már el lett mentve.");
    tx.set(mine, { author_uid: request.auth!.uid, role, rating, review, created_at: admin.firestore.FieldValue.serverTimestamp() });
    if (otherReview.exists) tx.update(ref, { reviews_visible: true, reviews_revealed_at: admin.firestore.FieldValue.serverTimestamp() });
    return { accepted: true, visible: otherReview.exists };
  });
});

/** A report is private, unique per participant/work and can only be resolved
 * by an administrator; a user cannot create a sanction for someone else. */
export const submitProblemTicket = onCall({ region: "europe-west3" }, async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Bejelentkezés szükséges.");
  const orderId = request.data?.orderId;
  const reason = typeof request.data?.reason === "string" ? request.data.reason.trim().slice(0, 120) : "";
  const description = typeof request.data?.description === "string" ? request.data.description.trim().slice(0, 3000) : "";
  if (typeof orderId !== "string" || !reason || !description) throw new HttpsError("invalid-argument", "Ok és leírás szükséges.");
  const order = await db.collection("orders").doc(orderId).get();
  const data = order.data();
  if (!order.exists || !data || (data.customer_uid !== request.auth.uid && data.provider_uid !== request.auth.uid)) throw new HttpsError("permission-denied", "Nincs jogosultságod ehhez a munkához.");
  const id = `${orderId}_${request.auth.uid}`;
  await db.collection("problem_tickets").doc(id).create({ order_id: orderId, reporter_uid: request.auth.uid, reason, description, status: "received", created_at: admin.firestore.FieldValue.serverTimestamp() });
  return { ticketId: id };
});
