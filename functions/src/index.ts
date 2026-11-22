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
      !answers.every((value: unknown) => Number.isInteger(value) && value >= 0 && value <= 2)) {
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
  const snap = await db.collection("orders").where("completed_at", "<=", cutoff).where("reviews_visible", "==", false).get();
  const batch = db.batch();
  snap.docs.forEach((doc) => batch.update(doc.ref, { reviews_visible: true, reviews_revealed_at: admin.firestore.FieldValue.serverTimestamp() }));
  if (!snap.empty) await batch.commit();
});
