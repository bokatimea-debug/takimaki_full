"""Repackage the verified unsigned APK with an isolated Android application ID.
Only the binary manifest string pool changes; Dart, DEX, resources and assets
remain byte-identical. zipalign and apksigner must run afterwards.
"""
import struct,zipfile,hashlib,json
from pathlib import Path
base=Path(__file__).resolve().parents[1]
src=base/'Takimaki_1.0.5_UNSIGNED_NOT_INSTALLABLE.apk'
assert hashlib.sha256(src.read_bytes()).hexdigest()=='06c854c1951ed311a50acd2c1a283038367853ef370656d7a005fb87297e30d9'
changes={'hu.takimaki.app':'hu.takimaki.test','Takimaki':'Takimaki Teszt','hu.takimaki.app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION':'hu.takimaki.test.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION','hu.takimaki.app.flutter.image_provider':'hu.takimaki.test.flutter.image_provider','hu.takimaki.app.androidx-startup':'hu.takimaki.test.androidx-startup'}
def patch(data):
    assert struct.unpack_from('<HH',data)==(3,8)
    pos=8;found=set()
    while pos<len(data):
        typ,hs,size=struct.unpack_from('<HHI',data,pos)
        if typ!=1:pos+=size;continue
        c=bytearray(data[pos:pos+size]);count,styles,flags,start,style_start=struct.unpack_from('<5I',c,8)
        assert styles==0 and style_start==0
        def length(p,utf8):
            if utf8:
                a=c[p];return (((a&127)<<8)|c[p+1],p+2) if a&128 else (a,p+1)
            a=struct.unpack_from('<H',c,p)[0];return (((a&32767)<<16)|struct.unpack_from('<H',c,p+2)[0],p+4) if a&32768 else (a,p+2)
        utf8=bool(flags&256);pool=bytearray();offsets=[]
        for i in range(count):
            p=start+struct.unpack_from('<I',c,hs+4*i)[0];begin=p
            units,p=length(p,utf8)
            if utf8:
                n,p=length(p,True);s=bytes(c[p:p+n]).decode();end=p+n+1
            else:s=bytes(c[p:p+units*2]).decode('utf-16le');end=p+units*2+2
            offsets.append(len(pool))
            if s in changes:
                found.add(s);s=changes[s]
                if utf8:
                    b=s.encode();u=len(s.encode('utf-16le'))//2
                    assert u<128 and len(b)<128
                    pool.extend(bytes([u,len(b)])+b+b'\0')
                else:
                    b=s.encode('utf-16le');pool.extend(struct.pack('<H',len(b)//2)+b+b'\0\0')
            else:pool.extend(c[begin:end])
        pool.extend(b'\0'*(-len(pool)%4))
        head=c[:start]
        struct.pack_into('<I',head,4,start+len(pool))
        # Changing strings invalidates the sorted-string flag.
        struct.pack_into('<I',head,16,flags&~1)
        for i,v in enumerate(offsets):struct.pack_into('<I',head,hs+4*i,v)
        result=bytearray(data[:pos]+head+pool+data[pos+size:]);struct.pack_into('<I',result,4,len(result))
        assert found==set(changes),found
        return bytes(result)
    raise ValueError('No string pool')
out=base/'test-unaligned.apk'
with zipfile.ZipFile(src) as zi,zipfile.ZipFile(out,'w') as zo:
    for item in zi.infolist():
        b=zi.read(item.filename)
        if item.filename=='AndroidManifest.xml':b=patch(b)
        zo.writestr(item,b)
with zipfile.ZipFile(src) as a,zipfile.ZipFile(out) as b:
    assert a.namelist()==b.namelist()
    changed=[n for n in a.namelist() if a.read(n)!=b.read(n)]
    assert changed==['AndroidManifest.xml']
(base/'verification/repackage-check.json').write_text(json.dumps({'only_changed_entry':changed,'input_sha256':hashlib.sha256(src.read_bytes()).hexdigest(),'new_package':'hu.takimaki.test','label':'Takimaki Teszt'},indent=2))
print('Manifest updated; every other APK entry byte-identical.')
