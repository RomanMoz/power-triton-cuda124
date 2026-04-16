; ModuleID = '/home/powerai/triton/python/triton/experimental/gsan/src/GSanLibrary.cu'
source_filename = "/home/powerai/triton/python/triton/experimental/gsan/src/GSanLibrary.cu"
target datalayout = "e-p6:32:32-i64:64-i128:128-i256:256-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

%"struct.gsan::Location" = type { ptr, i32 }

@.str = private unnamed_addr constant [10 x i8] c"<unknown>\00", align 1
@.str3 = private unnamed_addr constant [31 x i8] c"Read after write race detected\00", align 1
@.str4 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1
@.str5 = private unnamed_addr constant [24 x i8] c"Vector clock overflowed\00", align 1
@.str6 = private unnamed_addr constant [31 x i8] c"Write after read race detected\00", align 1
@.str7 = private unnamed_addr constant [32 x i8] c"Write after write race detected\00", align 1

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn denormal_fpenv(float: preservesign) memory(argmem: read)
define dso_local noundef nonnull ptr @_ZN4gsan13getSourceFileENS_8LocationE(ptr noundef readonly byval(%"struct.gsan::Location") align 8 captures(none) %loc) local_unnamed_addr #0 {
entry:
  %0 = load ptr, ptr %loc, align 8, !tbaa !7
  %cmp = icmp eq ptr %0, null
  %cond = select i1 %cmp, ptr @.str, ptr %0
  ret ptr %cond
}

; Function Attrs: convergent mustprogress nounwind denormal_fpenv(float: preservesign)
define dso_local void @__triton_gsan_load_tensor(ptr noundef %globalState, ptr noundef readonly captures(none) %stackPtr, i32 noundef %numElems, i32 noundef %bytesPerElem, ptr noundef %file, i32 noundef %line) local_unnamed_addr #1 {
entry:
  %lock.sroa.0.i28.i.i = alloca ptr, align 8
  %threadNumReadsAtomic.sroa.0.i.i.i = alloca ptr, align 8
  %lock.sroa.0.i.i.i = alloca ptr, align 8
  %atom.sroa.0.i20.i.i = alloca ptr, align 8
  %atom.sroa.0.i.i.i = alloca ptr, align 8
  %0 = tail call noundef i32 asm "mov.b32 $0, %smid;", "=r"() #6, !srcloc !11
  %1 = ptrtoint ptr %globalState to i64
  %ptr.biased.i.i = add i64 %1, 39
  %cond.i.i = and i64 %ptr.biased.i.i, -8
  %2 = getelementptr i8, ptr %globalState, i64 24
  %globals.val.i = load i16, ptr %2, align 8, !tbaa !12
  %3 = getelementptr i8, ptr %globalState, i64 26
  %globals.val24.i = load i16, ptr %3, align 2, !tbaa !16
  %conv.i.i = zext i16 %globals.val24.i to i64
  %add.i.i = add nuw nsw i64 %conv.i.i, 1
  %conv1.i.i = zext i16 %globals.val.i to i64
  %mul.i.i = shl nuw nsw i64 %conv1.i.i, 1
  %mul3.i.i = mul nuw nsw i64 %mul.i.i, %add.i.i
  %add4.i.i = add nuw nsw i64 %mul3.i.i, 32
  %conv.i = zext i32 %0 to i64
  %mul.i = mul i64 %add4.i.i, %conv.i
  %add3.i = add i64 %mul.i, %cond.i.i
  %4 = inttoptr i64 %add3.i to ptr
  %5 = load ptr, ptr %4, align 8, !tbaa !17
  %cmp.i = icmp eq ptr %5, null
  br i1 %cmp.i, label %if.then.i, label %_ZN4gsan12_GLOBAL__N_114getThreadStateEPNS_11GlobalStateE.exit

if.then.i:                                        ; preds = %entry
  %6 = load i64, ptr %globalState, align 8, !tbaa !19
  %reserveBase5.i = getelementptr inbounds nuw i8, ptr %4, i64 8
  store i64 %6, ptr %reserveBase5.i, align 8, !tbaa !20
  %numReads.i = getelementptr inbounds nuw i8, ptr %4, i64 16
  store i32 0, ptr %numReads.i, align 8, !tbaa !3
  %clockBufferDirty.i = getelementptr inbounds nuw i8, ptr %4, i64 20
  store i32 0, ptr %clockBufferDirty.i, align 4
  %globalsBase1.i.i = getelementptr inbounds nuw i8, ptr %globalState, i64 8
  %7 = load i64, ptr %globalsBase1.i.i, align 8, !tbaa !21
  %sub.i.i = sub i64 %1, %7
  %div6.i.i = lshr i64 %sub.i.i, 30
  %numSms.i.i = getelementptr inbounds nuw i8, ptr %globalState, i64 20
  %8 = load i16, ptr %numSms.i.i, align 4, !tbaa !22
  %conv.i25.i = zext i16 %8 to i64
  %mul.i26.i = mul nuw nsw i64 %div6.i.i, %conv.i25.i
  %add.i27.i = add nuw nsw i64 %mul.i26.i, %conv.i
  %conv3.i.i = trunc i64 %add.i27.i to i16
  %threadId.i = getelementptr inbounds nuw i8, ptr %4, i64 28
  store i16 %conv3.i.i, ptr %threadId.i, align 4, !tbaa !23
  tail call void asm sideeffect "fence.acq_rel.gpu;", "~{memory}"() #7, !srcloc !24
  store ptr %globalState, ptr %4, align 8, !tbaa !17
  br label %_ZN4gsan12_GLOBAL__N_114getThreadStateEPNS_11GlobalStateE.exit

_ZN4gsan12_GLOBAL__N_114getThreadStateEPNS_11GlobalStateE.exit: ; preds = %entry, %if.then.i
  %conv.i4 = sext i32 %numElems to i64
  %mul.i5 = shl nsw i64 %conv.i4, 3
  %add.ptr.i = getelementptr inbounds nuw i8, ptr %stackPtr, i64 %mul.i5
  %cmp9.i = icmp sgt i32 %numElems, 0
  br i1 %cmp9.i, label %for.body.lr.ph.i, label %_ZN4gsan12_GLOBAL__N_110tensorLoadEPNS_11ThreadStateEPKciiNS_8LocationE.exit

for.body.lr.ph.i:                                 ; preds = %_ZN4gsan12_GLOBAL__N_114getThreadStateEPNS_11GlobalStateE.exit
  %conv.i.i6 = sext i32 %bytesPerElem to i64
  %reserveBase1.i.i = getelementptr inbounds nuw i8, ptr %4, i64 8
  %lock.i.i = getelementptr inbounds nuw i8, ptr %4, i64 24
  %vectorClock.i.i.i = getelementptr inbounds nuw i8, ptr %4, i64 30
  %cmp.i.i.i.i = icmp eq ptr %file, null
  %cond.i.i.i.i = select i1 %cmp.i.i.i.i, ptr @.str, ptr %file
  %threadId8.i.i.i = getelementptr inbounds nuw i8, ptr %4, i64 28
  %numReads38.i.i.i = getelementptr inbounds nuw i8, ptr %4, i64 16
  %and.i.i27.i.i = and i64 %add3.i, -1073741824
  %9 = inttoptr i64 %and.i.i27.i.i to ptr
  %rngSeed.i.i.i = getelementptr inbounds nuw i8, ptr %9, i64 16
  br label %for.body.i

for.body.i:                                       ; preds = %if.end.i, %for.body.lr.ph.i
  %i.010.i = phi i32 [ 0, %for.body.lr.ph.i ], [ %inc.i, %if.end.i ]
  %idxprom.i = zext nneg i32 %i.010.i to i64
  %arrayidx2.i = getelementptr inbounds nuw i8, ptr %add.ptr.i, i64 %idxprom.i
  %10 = load i8, ptr %arrayidx2.i, align 1, !tbaa !25
  %tobool.not.i = icmp eq i8 %10, 0
  br i1 %tobool.not.i, label %if.end.i, label %if.then.i7

if.then.i7:                                       ; preds = %for.body.i
  %arrayidx.i = getelementptr inbounds nuw [8 x i8], ptr %stackPtr, i64 %idxprom.i
  %11 = load i64, ptr %arrayidx.i, align 8, !tbaa !20
  %add.i.i8 = add i64 %11, %conv.i.i6
  %sub.i.i.i = and i64 %11, -4
  %rem3.i.i.i = and i64 %add.i.i8, 3
  %cmp.i.i.i = icmp eq i64 %rem3.i.i.i, 0
  %sub5.i.i.i = sub nuw nsw i64 4, %rem3.i.i.i
  %cond.i.i.i = select i1 %cmp.i.i.i, i64 0, i64 %sub5.i.i.i
  %add.i.i.i = add i64 %cond.i.i.i, %add.i.i8
  %12 = load i64, ptr %reserveBase1.i.i, align 8, !tbaa !20
  call void @llvm.lifetime.start.p0(ptr nonnull %atom.sroa.0.i.i.i)
  store ptr %lock.i.i, ptr %atom.sroa.0.i.i.i, align 8, !tbaa !26
  %atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.0.atom.sroa.0.i.i.0.atom.sroa.0.i.0.atom.sroa.0.i.0.atom.sroa.0.0.atom.sroa.0.0.atom.sroa.0.0..i.i.i = load volatile ptr, ptr %atom.sroa.0.i.i.i, align 8, !tbaa !28
  %13 = tail call i32 asm sideeffect "atom.add.acquire.cta.u32 $0,[$1],$2;", "=r,l,r,~{memory}"(ptr %atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.0.atom.sroa.0.i.i.0.atom.sroa.0.i.0.atom.sroa.0.i.0.atom.sroa.0.0.atom.sroa.0.0.atom.sroa.0.0..i.i.i, i32 1) #7, !srcloc !30
  %cmp.i19.i.i = icmp sgt i32 %13, -1
  br i1 %cmp.i19.i.i, label %_ZN4gsan12_GLOBAL__N_117rwLockAcquireReadERj.exit.i.i, label %do.body.i.i.i

do.body.i.i.i:                                    ; preds = %if.then.i7, %do.body.i.i.i
  %atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.0.atom.sroa.0.i.i.0.atom.sroa.0.i.0.atom.sroa.0.i.0.atom.sroa.0.0.atom.sroa.0.0.atom.sroa.0.0.6.i.i.i = load volatile ptr, ptr %atom.sroa.0.i.i.i, align 8, !tbaa !28
  %14 = tail call i32 asm sideeffect "ld.acquire.cta.b32 $0,[$1];", "=r,l,~{memory}"(ptr %atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.0.atom.sroa.0.i.i.0.atom.sroa.0.i.0.atom.sroa.0.i.0.atom.sroa.0.0.atom.sroa.0.0.atom.sroa.0.0.6.i.i.i) #7, !srcloc !31
  %cmp3.not.i.i.i = icmp sgt i32 %14, -1
  br i1 %cmp3.not.i.i.i, label %_ZN4gsan12_GLOBAL__N_117rwLockAcquireReadERj.exit.i.i, label %do.body.i.i.i, !llvm.loop !32

_ZN4gsan12_GLOBAL__N_117rwLockAcquireReadERj.exit.i.i: ; preds = %do.body.i.i.i, %if.then.i7
  call void @llvm.lifetime.end.p0(ptr nonnull %atom.sroa.0.i.i.i)
  %cmp31.i.i = icmp ult i64 %sub.i.i.i, %add.i.i.i
  br i1 %cmp31.i.i, label %for.body.i.i, label %_ZN4gsan12_GLOBAL__N_19readRangeEPNS_11ThreadStateEmiNS_8LocationE.exit.i

for.body.i.i:                                     ; preds = %_ZN4gsan12_GLOBAL__N_117rwLockAcquireReadERj.exit.i.i, %for.inc.i.i
  %addr.032.i.i = phi i64 [ %add8.i.i, %for.inc.i.i ], [ %sub.i.i.i, %_ZN4gsan12_GLOBAL__N_117rwLockAcquireReadERj.exit.i.i ]
  %and.i.i.i.i = and i64 %addr.032.i.i, -1099511627776
  %cmp.i22.i.i = icmp eq i64 %and.i.i.i.i, %12
  br i1 %cmp.i22.i.i, label %if.end.i.i, label %for.inc.i.i

if.end.i.i:                                       ; preds = %for.body.i.i
  %reass.sub = sub i64 %addr.032.i.i, %12
  %sub.i24.i.i = add i64 %reass.sub, -549755813888
  %div4.i.i.i = lshr exact i64 %sub.i24.i.i, 2
  %mul.i.i.i = mul i64 %div4.i.i.i, 28
  %add.i25.i.i = add i64 %mul.i.i.i, %12
  %15 = inttoptr i64 %add.i25.i.i to ptr
  call void @llvm.lifetime.start.p0(ptr nonnull %lock.sroa.0.i.i.i)
  %lock1.i.i.i = getelementptr inbounds nuw i8, ptr %15, i64 24
  store ptr %lock1.i.i.i, ptr %lock.sroa.0.i.i.i, align 8, !tbaa !26
  br label %while.cond.i.i.i

while.cond.i.i.i:                                 ; preds = %while.cond.i.i.i, %if.end.i.i
  %lock.sroa.0.i.i.i.0.lock.sroa.0.i.i.i.0.lock.sroa.0.i.i.i.0.lock.sroa.0.i.i.0.lock.sroa.0.i.i.0.lock.sroa.0.i.0.lock.sroa.0.i.0.lock.sroa.0.0.lock.sroa.0.0.lock.sroa.0.0..i.i.i = load volatile ptr, ptr %lock.sroa.0.i.i.i, align 8, !tbaa !34
  %16 = tail call i32 asm sideeffect "atom.cas.acquire.sys.b32 $0,[$1],$2,$3;", "=r,l,r,r,~{memory}"(ptr %lock.sroa.0.i.i.i.0.lock.sroa.0.i.i.i.0.lock.sroa.0.i.i.i.0.lock.sroa.0.i.i.0.lock.sroa.0.i.i.0.lock.sroa.0.i.0.lock.sroa.0.i.0.lock.sroa.0.0.lock.sroa.0.0.lock.sroa.0.0..i.i.i, i32 0, i32 1) #7, !srcloc !36
  %cmp.i.i.i.i.i.i = icmp eq i32 %16, 0
  br i1 %cmp.i.i.i.i.i.i, label %_ZN4gsan12_GLOBAL__N_113acquireShadowEm.exit.i.i, label %while.cond.i.i.i, !llvm.loop !37

_ZN4gsan12_GLOBAL__N_113acquireShadowEm.exit.i.i: ; preds = %while.cond.i.i.i
  call void @llvm.lifetime.end.p0(ptr nonnull %lock.sroa.0.i.i.i)
  %numReads1.i.i.i = getelementptr inbounds nuw i8, ptr %15, i64 20
  %17 = load i32, ptr %numReads1.i.i.i, align 4, !tbaa !38
  %cmp.not.i.i.i = icmp eq i32 %17, -1
  br i1 %cmp.not.i.i.i, label %if.end.i.i.i, label %if.then.i.i.i

if.then.i.i.i:                                    ; preds = %_ZN4gsan12_GLOBAL__N_113acquireShadowEm.exit.i.i
  %inc.i.i.i = add nuw i32 %17, 1
  store i32 %inc.i.i.i, ptr %numReads1.i.i.i, align 4, !tbaa !38
  br label %if.end.i.i.i

if.end.i.i.i:                                     ; preds = %if.then.i.i.i, %_ZN4gsan12_GLOBAL__N_113acquireShadowEm.exit.i.i
  %writeClock.i.i.i = getelementptr inbounds nuw i8, ptr %15, i64 16
  %write.sroa.0.0.copyload.i.i.i = load i16, ptr %writeClock.i.i.i, align 4, !tbaa !23
  %write.sroa.4.0.writeClock.sroa_idx.i.i.i = getelementptr inbounds nuw i8, ptr %15, i64 18
  %write.sroa.4.0.copyload.i.i.i = load i16, ptr %write.sroa.4.0.writeClock.sroa_idx.i.i.i, align 2, !tbaa !25
  %bf.clear.i.i.i = and i16 %write.sroa.4.0.copyload.i.i.i, 4095
  %idxprom.i.i.i = zext nneg i16 %bf.clear.i.i.i to i64
  %arrayidx.i.i.i = getelementptr inbounds nuw [2 x i8], ptr %vectorClock.i.i.i, i64 %idxprom.i.i.i
  %18 = load i16, ptr %arrayidx.i.i.i, align 2, !tbaa !23
  %cmp4.not.i.i.i = icmp ult i16 %18, %write.sroa.0.0.copyload.i.i.i
  br i1 %cmp4.not.i.i.i, label %if.then5.i.i.i, label %do.end.i.i.i

if.then5.i.i.i:                                   ; preds = %if.end.i.i.i
  tail call void @__assertfail(ptr noundef nonnull @.str3, ptr noundef nonnull %cond.i.i.i.i, i32 noundef %line, ptr noundef nonnull @.str4, i64 noundef 1) #8
  br label %do.end.i.i.i

do.end.i.i.i:                                     ; preds = %if.then5.i.i.i, %if.end.i.i.i
  %19 = load i16, ptr %threadId8.i.i.i, align 4, !tbaa !23
  %idxprom10.i.i.i = zext i16 %19 to i64
  %arrayidx11.i.i.i = getelementptr inbounds nuw [2 x i8], ptr %vectorClock.i.i.i, i64 %idxprom10.i.i.i
  %20 = load i16, ptr %arrayidx11.i.i.i, align 2, !tbaa !23
  %bf.value.i.i.i = and i16 %19, 4095
  %readClock.sroa.0.0.copyload.i.i.i = load i16, ptr %15, align 4, !tbaa !23
  %readClock.sroa.4.0.arrayidx20.sroa_idx.i.i.i = getelementptr inbounds nuw i8, ptr %15, i64 2
  %readClock.sroa.4.0.copyload.i.i.i = load i16, ptr %readClock.sroa.4.0.arrayidx20.sroa_idx.i.i.i, align 2, !tbaa !25
  %bf.clear23.i.i.i = and i16 %readClock.sroa.4.0.copyload.i.i.i, 4095
  %cmp26.i.i.i = icmp ne i16 %bf.clear23.i.i.i, %19
  %cmp29.i.i.i = icmp ne i16 %readClock.sroa.0.0.copyload.i.i.i, 0
  %or.cond.not.i.i.i = select i1 %cmp26.i.i.i, i1 %cmp29.i.i.i, i1 false
  br i1 %or.cond.not.i.i.i, label %for.cond.i.i.i, label %if.then30.i.i.i

for.cond.i.i.i:                                   ; preds = %do.end.i.i.i
  %arrayidx20.1.i.i.i = getelementptr inbounds nuw i8, ptr %15, i64 4
  %readClock.sroa.0.0.copyload.1.i.i.i = load i16, ptr %arrayidx20.1.i.i.i, align 4, !tbaa !23
  %readClock.sroa.4.0.arrayidx20.sroa_idx.1.i.i.i = getelementptr inbounds nuw i8, ptr %15, i64 6
  %readClock.sroa.4.0.copyload.1.i.i.i = load i16, ptr %readClock.sroa.4.0.arrayidx20.sroa_idx.1.i.i.i, align 2, !tbaa !25
  %bf.clear23.1.i.i.i = and i16 %readClock.sroa.4.0.copyload.1.i.i.i, 4095
  %cmp26.1.i.i.i = icmp ne i16 %bf.clear23.1.i.i.i, %19
  %cmp29.1.i.i.i = icmp ne i16 %readClock.sroa.0.0.copyload.1.i.i.i, 0
  %or.cond.not.1.i.i.i = select i1 %cmp26.1.i.i.i, i1 %cmp29.1.i.i.i, i1 false
  br i1 %or.cond.not.1.i.i.i, label %for.cond.1.i.i.i, label %if.then30.i.i.i

for.cond.1.i.i.i:                                 ; preds = %for.cond.i.i.i
  %arrayidx20.2.i.i.i = getelementptr inbounds nuw i8, ptr %15, i64 8
  %readClock.sroa.0.0.copyload.2.i.i.i = load i16, ptr %arrayidx20.2.i.i.i, align 4, !tbaa !23
  %readClock.sroa.4.0.arrayidx20.sroa_idx.2.i.i.i = getelementptr inbounds nuw i8, ptr %15, i64 10
  %readClock.sroa.4.0.copyload.2.i.i.i = load i16, ptr %readClock.sroa.4.0.arrayidx20.sroa_idx.2.i.i.i, align 2, !tbaa !25
  %bf.clear23.2.i.i.i = and i16 %readClock.sroa.4.0.copyload.2.i.i.i, 4095
  %cmp26.2.i.i.i = icmp ne i16 %bf.clear23.2.i.i.i, %19
  %cmp29.2.i.i.i = icmp ne i16 %readClock.sroa.0.0.copyload.2.i.i.i, 0
  %or.cond.not.2.i.i.i = select i1 %cmp26.2.i.i.i, i1 %cmp29.2.i.i.i, i1 false
  br i1 %or.cond.not.2.i.i.i, label %for.cond.2.i.i.i, label %if.then30.i.i.i

for.cond.2.i.i.i:                                 ; preds = %for.cond.1.i.i.i
  %arrayidx20.3.i.i.i = getelementptr inbounds nuw i8, ptr %15, i64 12
  %readClock.sroa.0.0.copyload.3.i.i.i = load i16, ptr %arrayidx20.3.i.i.i, align 4, !tbaa !23
  %readClock.sroa.4.0.arrayidx20.sroa_idx.3.i.i.i = getelementptr inbounds nuw i8, ptr %15, i64 14
  %readClock.sroa.4.0.copyload.3.i.i.i = load i16, ptr %readClock.sroa.4.0.arrayidx20.sroa_idx.3.i.i.i, align 2, !tbaa !25
  %bf.clear23.3.i.i.i = and i16 %readClock.sroa.4.0.copyload.3.i.i.i, 4095
  %cmp26.3.i.i.i = icmp ne i16 %bf.clear23.3.i.i.i, %19
  %cmp29.3.i.i.i = icmp ne i16 %readClock.sroa.0.0.copyload.3.i.i.i, 0
  %or.cond.not.3.i.i.i = select i1 %cmp26.3.i.i.i, i1 %cmp29.3.i.i.i, i1 false
  br i1 %or.cond.not.3.i.i.i, label %for.cond.3.i.i.i, label %if.then30.i.i.i

for.cond.3.i.i.i:                                 ; preds = %for.cond.2.i.i.i
  call void @llvm.lifetime.start.p0(ptr nonnull %threadNumReadsAtomic.sroa.0.i.i.i)
  store ptr %numReads38.i.i.i, ptr %threadNumReadsAtomic.sroa.0.i.i.i, align 8, !tbaa !26
  %threadNumReadsAtomic.sroa.0.i.i.i.0.threadNumReadsAtomic.sroa.0.i.i.i.0.threadNumReadsAtomic.sroa.0.i.i.i.0.threadNumReadsAtomic.sroa.0.i.i.0.threadNumReadsAtomic.sroa.0.i.i.0.threadNumReadsAtomic.sroa.0.i.0.threadNumReadsAtomic.sroa.0.i.0.threadNumReadsAtomic.sroa.0.0.threadNumReadsAtomic.sroa.0.0.threadNumReadsAtomic.sroa.0.0..i.i.i = load volatile ptr, ptr %threadNumReadsAtomic.sroa.0.i.i.i, align 8, !tbaa !28
  %21 = tail call i32 asm sideeffect "atom.add.relaxed.cta.u32 $0,[$1],$2;", "=r,l,r,~{memory}"(ptr %threadNumReadsAtomic.sroa.0.i.i.i.0.threadNumReadsAtomic.sroa.0.i.i.i.0.threadNumReadsAtomic.sroa.0.i.i.i.0.threadNumReadsAtomic.sroa.0.i.i.0.threadNumReadsAtomic.sroa.0.i.i.0.threadNumReadsAtomic.sroa.0.i.0.threadNumReadsAtomic.sroa.0.i.0.threadNumReadsAtomic.sroa.0.0.threadNumReadsAtomic.sroa.0.0.threadNumReadsAtomic.sroa.0.0..i.i.i, i32 1) #7, !srcloc !42
  %22 = load i32, ptr %rngSeed.i.i.i, align 16, !tbaa !43
  %23 = load i16, ptr %threadId8.i.i.i, align 4, !tbaa !23
  %conv42.i.i.i = zext i16 %23 to i32
  %mul.i.i.i.i.i.i = mul i32 %21, -862048943
  %or.i.i.i.i.i.i.i = tail call noundef i32 @llvm.fshl.i32(i32 %mul.i.i.i.i.i.i, i32 %mul.i.i.i.i.i.i, i32 15)
  %mul1.i.i.i.i.i.i = mul i32 %or.i.i.i.i.i.i.i, 461845907
  %xor.i.i.i.i.i = xor i32 %mul1.i.i.i.i.i.i, %22
  %or.i.i.i.i.i.i = tail call noundef i32 @llvm.fshl.i32(i32 %xor.i.i.i.i.i, i32 %xor.i.i.i.i.i, i32 13)
  %mul.i.i.i.i.i = mul i32 %or.i.i.i.i.i.i, 5
  %add.i.i.i.i.i = add i32 %mul.i.i.i.i.i, -430675100
  %mul.i.i6.i.i.i.i = mul i32 %conv42.i.i.i, -862048943
  %or.i.i.i7.i.i.i.i = tail call noundef i32 @llvm.fshl.i32(i32 %mul.i.i6.i.i.i.i, i32 %mul.i.i6.i.i.i.i, i32 15)
  %mul1.i.i8.i.i.i.i = mul i32 %or.i.i.i7.i.i.i.i, 461845907
  %xor.i9.i.i.i.i = xor i32 %add.i.i.i.i.i, %mul1.i.i8.i.i.i.i
  %or.i.i10.i.i.i.i = tail call noundef i32 @llvm.fshl.i32(i32 %xor.i9.i.i.i.i, i32 %xor.i9.i.i.i.i, i32 13)
  %mul.i11.i.i.i.i = mul i32 %or.i.i10.i.i.i.i, 5
  %add.i12.i.i.i.i = add i32 %mul.i11.i.i.i.i, -430675100
  %shr.i.i.i.i.i = lshr i32 %add.i12.i.i.i.i, 16
  %24 = xor i32 %add.i12.i.i.i.i, %shr.i.i.i.i.i
  %xor.i13.i.i.i.i = xor i32 %24, 8
  %mul.i14.i.i.i.i = mul i32 %xor.i13.i.i.i.i, -2048144789
  %shr1.i.i.i.i.i = lshr i32 %mul.i14.i.i.i.i, 13
  %xor2.i.i.i.i.i = xor i32 %shr1.i.i.i.i.i, %mul.i14.i.i.i.i
  %mul3.i.i.i.i.i = mul i32 %xor2.i.i.i.i.i, -1028477387
  %shr4.i.i.i.i.i = lshr i32 %mul3.i.i.i.i.i, 16
  %xor5.i.i.i.i.i = xor i32 %shr4.i.i.i.i.i, %mul3.i.i.i.i.i
  %shr.i.i.i = lshr i32 %xor5.i.i.i.i.i, 8
  %rem.i.i.i = urem i32 %shr.i.i.i, %17
  %cmp44.not.i.i.i = icmp eq i32 %rem.i.i.i, 0
  br i1 %cmp44.not.i.i.i, label %if.end46.i.i.i, label %cleanup51.i.i.i

if.then30.i.i.i:                                  ; preds = %for.cond.2.i.i.i, %for.cond.1.i.i.i, %for.cond.i.i.i, %do.end.i.i.i
  %arrayidx20.lcssa.i.i.i = phi ptr [ %15, %do.end.i.i.i ], [ %arrayidx20.1.i.i.i, %for.cond.i.i.i ], [ %arrayidx20.2.i.i.i, %for.cond.1.i.i.i ], [ %arrayidx20.3.i.i.i, %for.cond.2.i.i.i ]
  %readClock.sroa.4.0.arrayidx20.sroa_idx.le.i.i.i = getelementptr inbounds nuw i8, ptr %arrayidx20.lcssa.i.i.i, i64 2
  store i16 %20, ptr %arrayidx20.lcssa.i.i.i, align 4, !tbaa !23
  store i16 %bf.value.i.i.i, ptr %readClock.sroa.4.0.arrayidx20.sroa_idx.le.i.i.i, align 2, !tbaa !25
  br label %_ZN4gsan12_GLOBAL__N_16doReadEPNS_11ThreadStateEPNS_10ShadowCellENS_8LocationE.exit.i.i

if.end46.i.i.i:                                   ; preds = %for.cond.3.i.i.i
  %rem47.i.i.i = and i32 %xor5.i.i.i.i.i, 3
  %idxprom49.i.i.i = zext nneg i32 %rem47.i.i.i to i64
  %arrayidx50.i.i.i = getelementptr inbounds nuw [4 x i8], ptr %15, i64 %idxprom49.i.i.i
  %scalarClock.sroa.5.0.arrayidx50.sroa_idx.i.i.i = getelementptr inbounds nuw i8, ptr %arrayidx50.i.i.i, i64 2
  store i16 %20, ptr %arrayidx50.i.i.i, align 4, !tbaa !23
  store i16 %bf.value.i.i.i, ptr %scalarClock.sroa.5.0.arrayidx50.sroa_idx.i.i.i, align 2, !tbaa !25
  br label %cleanup51.i.i.i

cleanup51.i.i.i:                                  ; preds = %if.end46.i.i.i, %for.cond.3.i.i.i
  call void @llvm.lifetime.end.p0(ptr nonnull %threadNumReadsAtomic.sroa.0.i.i.i)
  br label %_ZN4gsan12_GLOBAL__N_16doReadEPNS_11ThreadStateEPNS_10ShadowCellENS_8LocationE.exit.i.i

_ZN4gsan12_GLOBAL__N_16doReadEPNS_11ThreadStateEPNS_10ShadowCellENS_8LocationE.exit.i.i: ; preds = %cleanup51.i.i.i, %if.then30.i.i.i
  call void @llvm.lifetime.start.p0(ptr nonnull %lock.sroa.0.i28.i.i)
  store ptr %lock1.i.i.i, ptr %lock.sroa.0.i28.i.i, align 8, !tbaa !26
  %lock.sroa.0.i28.i.i.0.lock.sroa.0.i28.i.i.0.lock.sroa.0.i28.i.i.0.lock.sroa.0.i28.i.0.lock.sroa.0.i28.i.0.lock.sroa.0.i28.0.lock.sroa.0.i28.0.lock.sroa.0.0.lock.sroa.0.0.lock.sroa.0.0..i30.i.i = load volatile ptr, ptr %lock.sroa.0.i28.i.i, align 8, !tbaa !34
  tail call void asm sideeffect "st.release.sys.b32 [$0], $1;", "l,r,~{memory}"(ptr %lock.sroa.0.i28.i.i.0.lock.sroa.0.i28.i.i.0.lock.sroa.0.i28.i.i.0.lock.sroa.0.i28.i.0.lock.sroa.0.i28.i.0.lock.sroa.0.i28.0.lock.sroa.0.i28.0.lock.sroa.0.0.lock.sroa.0.0.lock.sroa.0.0..i30.i.i, i32 0) #7, !srcloc !44
  call void @llvm.lifetime.end.p0(ptr nonnull %lock.sroa.0.i28.i.i)
  br label %for.inc.i.i

for.inc.i.i:                                      ; preds = %_ZN4gsan12_GLOBAL__N_16doReadEPNS_11ThreadStateEPNS_10ShadowCellENS_8LocationE.exit.i.i, %for.body.i.i
  %add8.i.i = add i64 %addr.032.i.i, 4
  %cmp.i.i = icmp ult i64 %add8.i.i, %add.i.i.i
  br i1 %cmp.i.i, label %for.body.i.i, label %_ZN4gsan12_GLOBAL__N_19readRangeEPNS_11ThreadStateEmiNS_8LocationE.exit.i, !llvm.loop !45

_ZN4gsan12_GLOBAL__N_19readRangeEPNS_11ThreadStateEmiNS_8LocationE.exit.i: ; preds = %for.inc.i.i, %_ZN4gsan12_GLOBAL__N_117rwLockAcquireReadERj.exit.i.i
  call void @llvm.lifetime.start.p0(ptr nonnull %atom.sroa.0.i20.i.i)
  store ptr %lock.i.i, ptr %atom.sroa.0.i20.i.i, align 8, !tbaa !26
  %atom.sroa.0.i20.i.i.0.atom.sroa.0.i20.i.i.0.atom.sroa.0.i20.i.i.0.atom.sroa.0.i20.i.0.atom.sroa.0.i20.i.0.atom.sroa.0.i20.0.atom.sroa.0.i20.0.atom.sroa.0.0.atom.sroa.0.0.atom.sroa.0.0..i21.i.i = load volatile ptr, ptr %atom.sroa.0.i20.i.i, align 8, !tbaa !28
  %25 = tail call i32 asm sideeffect "atom.add.relaxed.cta.u32 $0,[$1],$2;", "=r,l,r,~{memory}"(ptr %atom.sroa.0.i20.i.i.0.atom.sroa.0.i20.i.i.0.atom.sroa.0.i20.i.i.0.atom.sroa.0.i20.i.0.atom.sroa.0.i20.i.0.atom.sroa.0.i20.0.atom.sroa.0.i20.0.atom.sroa.0.0.atom.sroa.0.0.atom.sroa.0.0..i21.i.i, i32 -1) #7, !srcloc !46
  call void @llvm.lifetime.end.p0(ptr nonnull %atom.sroa.0.i20.i.i)
  br label %if.end.i

if.end.i:                                         ; preds = %_ZN4gsan12_GLOBAL__N_19readRangeEPNS_11ThreadStateEmiNS_8LocationE.exit.i, %for.body.i
  %inc.i = add nuw nsw i32 %i.010.i, 1
  %exitcond.not.i = icmp eq i32 %inc.i, %numElems
  br i1 %exitcond.not.i, label %_ZN4gsan12_GLOBAL__N_110tensorLoadEPNS_11ThreadStateEPKciiNS_8LocationE.exit, label %for.body.i, !llvm.loop !47

_ZN4gsan12_GLOBAL__N_110tensorLoadEPNS_11ThreadStateEPKciiNS_8LocationE.exit: ; preds = %if.end.i, %_ZN4gsan12_GLOBAL__N_114getThreadStateEPNS_11GlobalStateE.exit
  ret void
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #2

; Function Attrs: convergent mustprogress nounwind denormal_fpenv(float: preservesign)
define dso_local void @__triton_gsan_init(ptr noundef %globalState, ptr noundef %file, i32 noundef %line) local_unnamed_addr #1 {
entry:
  %0 = tail call noundef i32 asm "mov.b32 $0, %smid;", "=r"() #6, !srcloc !11
  %1 = ptrtoint ptr %globalState to i64
  %ptr.biased.i.i.i = add i64 %1, 39
  %cond.i.i.i = and i64 %ptr.biased.i.i.i, -8
  %2 = getelementptr i8, ptr %globalState, i64 24
  %globals.val.i.i = load i16, ptr %2, align 8, !tbaa !12
  %3 = getelementptr i8, ptr %globalState, i64 26
  %globals.val24.i.i = load i16, ptr %3, align 2, !tbaa !16
  %conv.i.i.i = zext i16 %globals.val24.i.i to i64
  %add.i.i.i = add nuw nsw i64 %conv.i.i.i, 1
  %conv1.i.i.i = zext i16 %globals.val.i.i to i64
  %mul.i.i.i = shl nuw nsw i64 %conv1.i.i.i, 1
  %mul3.i.i.i = mul nuw nsw i64 %mul.i.i.i, %add.i.i.i
  %add4.i.i.i = add nuw nsw i64 %mul3.i.i.i, 32
  %conv.i.i = zext i32 %0 to i64
  %mul.i.i = mul i64 %add4.i.i.i, %conv.i.i
  %add3.i.i = add i64 %mul.i.i, %cond.i.i.i
  %4 = inttoptr i64 %add3.i.i to ptr
  %5 = load ptr, ptr %4, align 8, !tbaa !17
  %cmp.i.i = icmp eq ptr %5, null
  br i1 %cmp.i.i, label %if.then.i.i, label %_ZN4gsan12_GLOBAL__N_114getThreadStateEPNS_11GlobalStateE.exit.i

if.then.i.i:                                      ; preds = %entry
  %6 = load i64, ptr %globalState, align 8, !tbaa !19
  %reserveBase5.i.i = getelementptr inbounds nuw i8, ptr %4, i64 8
  store i64 %6, ptr %reserveBase5.i.i, align 8, !tbaa !20
  %numReads.i.i = getelementptr inbounds nuw i8, ptr %4, i64 16
  store i32 0, ptr %numReads.i.i, align 8, !tbaa !3
  %clockBufferDirty.i.i = getelementptr inbounds nuw i8, ptr %4, i64 20
  store i32 0, ptr %clockBufferDirty.i.i, align 4
  %globalsBase1.i.i.i = getelementptr inbounds nuw i8, ptr %globalState, i64 8
  %7 = load i64, ptr %globalsBase1.i.i.i, align 8, !tbaa !21
  %sub.i.i.i = sub i64 %1, %7
  %div6.i.i.i = lshr i64 %sub.i.i.i, 30
  %numSms.i.i.i = getelementptr inbounds nuw i8, ptr %globalState, i64 20
  %8 = load i16, ptr %numSms.i.i.i, align 4, !tbaa !22
  %conv.i25.i.i = zext i16 %8 to i64
  %mul.i26.i.i = mul nuw nsw i64 %div6.i.i.i, %conv.i25.i.i
  %add.i27.i.i = add nuw nsw i64 %mul.i26.i.i, %conv.i.i
  %conv3.i.i.i = trunc i64 %add.i27.i.i to i16
  %threadId.i.i = getelementptr inbounds nuw i8, ptr %4, i64 28
  store i16 %conv3.i.i.i, ptr %threadId.i.i, align 4, !tbaa !23
  tail call void asm sideeffect "fence.acq_rel.gpu;", "~{memory}"() #7, !srcloc !24
  store ptr %globalState, ptr %4, align 8, !tbaa !17
  br label %_ZN4gsan12_GLOBAL__N_114getThreadStateEPNS_11GlobalStateE.exit.i

_ZN4gsan12_GLOBAL__N_114getThreadStateEPNS_11GlobalStateE.exit.i: ; preds = %if.then.i.i, %entry
  %9 = tail call noundef i32 @llvm.nvvm.read.ptx.sreg.tid.x()
  %cmp.i = icmp eq i32 %9, 0
  br i1 %cmp.i, label %if.then.i, label %_ZN4gsan12_GLOBAL__N_110initThreadEPNS_11GlobalStateENS_8LocationE.exit

if.then.i:                                        ; preds = %_ZN4gsan12_GLOBAL__N_114getThreadStateEPNS_11GlobalStateE.exit.i
  %10 = tail call noundef i32 asm "mov.b32 $0, %smid;", "=r"() #6, !srcloc !11
  %globalsBase1.i.i = getelementptr inbounds nuw i8, ptr %globalState, i64 8
  %11 = load i64, ptr %globalsBase1.i.i, align 8, !tbaa !21
  %sub.i.i = sub i64 %1, %11
  %div6.i.i = lshr i64 %sub.i.i, 30
  %numSms.i.i = getelementptr inbounds nuw i8, ptr %globalState, i64 20
  %12 = load i16, ptr %numSms.i.i, align 4, !tbaa !22
  %conv.i17.i = zext i16 %12 to i64
  %mul.i18.i = mul nuw nsw i64 %div6.i.i, %conv.i17.i
  %conv2.i.i = zext i32 %10 to i64
  %add.i.i = add nuw nsw i64 %mul.i18.i, %conv2.i.i
  %vectorClock.i = getelementptr inbounds nuw i8, ptr %4, i64 30
  %idxprom.i = and i64 %add.i.i, 65535
  %arrayidx.i = getelementptr inbounds nuw [2 x i8], ptr %vectorClock.i, i64 %idxprom.i
  %13 = load i16, ptr %arrayidx.i, align 2, !tbaa !23
  %cmp6.not.i = icmp eq i16 %13, -1
  br i1 %cmp6.not.i, label %if.then7.i, label %do.end.i

if.then7.i:                                       ; preds = %if.then.i
  %cmp.i19.i = icmp eq ptr %file, null
  %cond.i.i = select i1 %cmp.i19.i, ptr @.str, ptr %file
  tail call void @__assertfail(ptr noundef nonnull @.str5, ptr noundef nonnull %cond.i.i, i32 noundef %line, ptr noundef nonnull @.str4, i64 noundef 1) #8
  %.pre.i = load i16, ptr %arrayidx.i, align 2, !tbaa !23
  br label %do.end.i

do.end.i:                                         ; preds = %if.then7.i, %if.then.i
  %14 = phi i16 [ %.pre.i, %if.then7.i ], [ %13, %if.then.i ]
  %add.i = add i16 %14, 1
  store i16 %add.i, ptr %arrayidx.i, align 2, !tbaa !23
  br label %_ZN4gsan12_GLOBAL__N_110initThreadEPNS_11GlobalStateENS_8LocationE.exit

_ZN4gsan12_GLOBAL__N_110initThreadEPNS_11GlobalStateENS_8LocationE.exit: ; preds = %_ZN4gsan12_GLOBAL__N_114getThreadStateEPNS_11GlobalStateE.exit.i, %do.end.i
  tail call void asm sideeffect "bar.sync 0;", "~{memory}"() #7, !srcloc !48
  ret void
}

; Function Attrs: convergent mustprogress nounwind denormal_fpenv(float: preservesign)
define dso_local void @__triton_gsan_store_tensor(ptr noundef %globalState, ptr noundef readonly captures(none) %stackPtr, i32 noundef %numElems, i32 noundef %bytesPerElem, ptr noundef %file, i32 noundef %line) local_unnamed_addr #1 {
entry:
  %lock.sroa.0.i27.i.i = alloca ptr, align 8
  %lock.sroa.0.i.i.i = alloca ptr, align 8
  %atom.sroa.0.i20.i.i = alloca ptr, align 8
  %atom.sroa.0.i.i.i = alloca ptr, align 8
  %0 = tail call noundef i32 asm "mov.b32 $0, %smid;", "=r"() #6, !srcloc !11
  %1 = ptrtoint ptr %globalState to i64
  %ptr.biased.i.i = add i64 %1, 39
  %cond.i.i = and i64 %ptr.biased.i.i, -8
  %2 = getelementptr i8, ptr %globalState, i64 24
  %globals.val.i = load i16, ptr %2, align 8, !tbaa !12
  %3 = getelementptr i8, ptr %globalState, i64 26
  %globals.val24.i = load i16, ptr %3, align 2, !tbaa !16
  %conv.i.i = zext i16 %globals.val24.i to i64
  %add.i.i = add nuw nsw i64 %conv.i.i, 1
  %conv1.i.i = zext i16 %globals.val.i to i64
  %mul.i.i = shl nuw nsw i64 %conv1.i.i, 1
  %mul3.i.i = mul nuw nsw i64 %mul.i.i, %add.i.i
  %add4.i.i = add nuw nsw i64 %mul3.i.i, 32
  %conv.i = zext i32 %0 to i64
  %mul.i = mul i64 %add4.i.i, %conv.i
  %add3.i = add i64 %mul.i, %cond.i.i
  %4 = inttoptr i64 %add3.i to ptr
  %5 = load ptr, ptr %4, align 8, !tbaa !17
  %cmp.i = icmp eq ptr %5, null
  br i1 %cmp.i, label %if.then.i, label %_ZN4gsan12_GLOBAL__N_114getThreadStateEPNS_11GlobalStateE.exit

if.then.i:                                        ; preds = %entry
  %6 = load i64, ptr %globalState, align 8, !tbaa !19
  %reserveBase5.i = getelementptr inbounds nuw i8, ptr %4, i64 8
  store i64 %6, ptr %reserveBase5.i, align 8, !tbaa !20
  %numReads.i = getelementptr inbounds nuw i8, ptr %4, i64 16
  store i32 0, ptr %numReads.i, align 8, !tbaa !3
  %clockBufferDirty.i = getelementptr inbounds nuw i8, ptr %4, i64 20
  store i32 0, ptr %clockBufferDirty.i, align 4
  %globalsBase1.i.i = getelementptr inbounds nuw i8, ptr %globalState, i64 8
  %7 = load i64, ptr %globalsBase1.i.i, align 8, !tbaa !21
  %sub.i.i = sub i64 %1, %7
  %div6.i.i = lshr i64 %sub.i.i, 30
  %numSms.i.i = getelementptr inbounds nuw i8, ptr %globalState, i64 20
  %8 = load i16, ptr %numSms.i.i, align 4, !tbaa !22
  %conv.i25.i = zext i16 %8 to i64
  %mul.i26.i = mul nuw nsw i64 %div6.i.i, %conv.i25.i
  %add.i27.i = add nuw nsw i64 %mul.i26.i, %conv.i
  %conv3.i.i = trunc i64 %add.i27.i to i16
  %threadId.i = getelementptr inbounds nuw i8, ptr %4, i64 28
  store i16 %conv3.i.i, ptr %threadId.i, align 4, !tbaa !23
  tail call void asm sideeffect "fence.acq_rel.gpu;", "~{memory}"() #7, !srcloc !24
  store ptr %globalState, ptr %4, align 8, !tbaa !17
  br label %_ZN4gsan12_GLOBAL__N_114getThreadStateEPNS_11GlobalStateE.exit

_ZN4gsan12_GLOBAL__N_114getThreadStateEPNS_11GlobalStateE.exit: ; preds = %entry, %if.then.i
  %conv.i4 = sext i32 %numElems to i64
  %mul.i5 = shl nsw i64 %conv.i4, 3
  %add.ptr.i = getelementptr inbounds nuw i8, ptr %stackPtr, i64 %mul.i5
  %cmp9.i = icmp sgt i32 %numElems, 0
  br i1 %cmp9.i, label %for.body.lr.ph.i, label %_ZN4gsan12_GLOBAL__N_111tensorStoreEPNS_11ThreadStateEPKciiNS_8LocationE.exit

for.body.lr.ph.i:                                 ; preds = %_ZN4gsan12_GLOBAL__N_114getThreadStateEPNS_11GlobalStateE.exit
  %conv.i.i6 = sext i32 %bytesPerElem to i64
  %reserveBase1.i.i = getelementptr inbounds nuw i8, ptr %4, i64 8
  %lock.i.i = getelementptr inbounds nuw i8, ptr %4, i64 24
  %vectorClock.i.i.i = getelementptr inbounds nuw i8, ptr %4, i64 30
  %cmp.i.i.i.i = icmp eq ptr %file, null
  %cond.i.i.i.i = select i1 %cmp.i.i.i.i, ptr @.str, ptr %file
  %threadId22.i.i.i = getelementptr inbounds nuw i8, ptr %4, i64 28
  br label %for.body.i

for.body.i:                                       ; preds = %if.end.i, %for.body.lr.ph.i
  %i.010.i = phi i32 [ 0, %for.body.lr.ph.i ], [ %inc.i, %if.end.i ]
  %idxprom.i = zext nneg i32 %i.010.i to i64
  %arrayidx2.i = getelementptr inbounds nuw i8, ptr %add.ptr.i, i64 %idxprom.i
  %9 = load i8, ptr %arrayidx2.i, align 1, !tbaa !25
  %tobool.not.i = icmp eq i8 %9, 0
  br i1 %tobool.not.i, label %if.end.i, label %if.then.i7

if.then.i7:                                       ; preds = %for.body.i
  %arrayidx.i = getelementptr inbounds nuw [8 x i8], ptr %stackPtr, i64 %idxprom.i
  %10 = load i64, ptr %arrayidx.i, align 8, !tbaa !20
  %add.i.i8 = add i64 %10, %conv.i.i6
  %sub.i.i.i = and i64 %10, -4
  %rem3.i.i.i = and i64 %add.i.i8, 3
  %cmp.i.i.i = icmp eq i64 %rem3.i.i.i, 0
  %sub5.i.i.i = sub nuw nsw i64 4, %rem3.i.i.i
  %cond.i.i.i = select i1 %cmp.i.i.i, i64 0, i64 %sub5.i.i.i
  %add.i.i.i = add i64 %cond.i.i.i, %add.i.i8
  %11 = load i64, ptr %reserveBase1.i.i, align 8, !tbaa !20
  call void @llvm.lifetime.start.p0(ptr nonnull %atom.sroa.0.i.i.i)
  store ptr %lock.i.i, ptr %atom.sroa.0.i.i.i, align 8, !tbaa !26
  %atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.0.atom.sroa.0.i.i.0.atom.sroa.0.i.0.atom.sroa.0.i.0.atom.sroa.0.0.atom.sroa.0.0.atom.sroa.0.0..i.i.i = load volatile ptr, ptr %atom.sroa.0.i.i.i, align 8, !tbaa !28
  %12 = tail call i32 asm sideeffect "atom.add.acquire.cta.u32 $0,[$1],$2;", "=r,l,r,~{memory}"(ptr %atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.0.atom.sroa.0.i.i.0.atom.sroa.0.i.0.atom.sroa.0.i.0.atom.sroa.0.0.atom.sroa.0.0.atom.sroa.0.0..i.i.i, i32 1) #7, !srcloc !30
  %cmp.i19.i.i = icmp sgt i32 %12, -1
  br i1 %cmp.i19.i.i, label %_ZN4gsan12_GLOBAL__N_117rwLockAcquireReadERj.exit.i.i, label %do.body.i.i.i

do.body.i.i.i:                                    ; preds = %if.then.i7, %do.body.i.i.i
  %atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.0.atom.sroa.0.i.i.0.atom.sroa.0.i.0.atom.sroa.0.i.0.atom.sroa.0.0.atom.sroa.0.0.atom.sroa.0.0.6.i.i.i = load volatile ptr, ptr %atom.sroa.0.i.i.i, align 8, !tbaa !28
  %13 = tail call i32 asm sideeffect "ld.acquire.cta.b32 $0,[$1];", "=r,l,~{memory}"(ptr %atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.i.0.atom.sroa.0.i.i.0.atom.sroa.0.i.i.0.atom.sroa.0.i.0.atom.sroa.0.i.0.atom.sroa.0.0.atom.sroa.0.0.atom.sroa.0.0.6.i.i.i) #7, !srcloc !31
  %cmp3.not.i.i.i = icmp sgt i32 %13, -1
  br i1 %cmp3.not.i.i.i, label %_ZN4gsan12_GLOBAL__N_117rwLockAcquireReadERj.exit.i.i, label %do.body.i.i.i, !llvm.loop !32

_ZN4gsan12_GLOBAL__N_117rwLockAcquireReadERj.exit.i.i: ; preds = %do.body.i.i.i, %if.then.i7
  call void @llvm.lifetime.end.p0(ptr nonnull %atom.sroa.0.i.i.i)
  %cmp30.i.i = icmp ult i64 %sub.i.i.i, %add.i.i.i
  br i1 %cmp30.i.i, label %for.body.i.i, label %_ZN4gsan12_GLOBAL__N_110writeRangeEPNS_11ThreadStateEmiNS_8LocationE.exit.i

for.body.i.i:                                     ; preds = %_ZN4gsan12_GLOBAL__N_117rwLockAcquireReadERj.exit.i.i, %for.inc.i.i
  %addr.031.i.i = phi i64 [ %add8.i.i, %for.inc.i.i ], [ %sub.i.i.i, %_ZN4gsan12_GLOBAL__N_117rwLockAcquireReadERj.exit.i.i ]
  %and.i.i.i.i = and i64 %addr.031.i.i, -1099511627776
  %cmp.i22.i.i = icmp eq i64 %and.i.i.i.i, %11
  br i1 %cmp.i22.i.i, label %if.end.i.i, label %for.inc.i.i

if.end.i.i:                                       ; preds = %for.body.i.i
  %reass.sub = sub i64 %addr.031.i.i, %11
  %sub.i24.i.i = add i64 %reass.sub, -549755813888
  %div4.i.i.i = lshr exact i64 %sub.i24.i.i, 2
  %mul.i.i.i = mul i64 %div4.i.i.i, 28
  %add.i25.i.i = add i64 %mul.i.i.i, %11
  %14 = inttoptr i64 %add.i25.i.i to ptr
  call void @llvm.lifetime.start.p0(ptr nonnull %lock.sroa.0.i.i.i)
  %lock1.i.i.i = getelementptr inbounds nuw i8, ptr %14, i64 24
  store ptr %lock1.i.i.i, ptr %lock.sroa.0.i.i.i, align 8, !tbaa !26
  br label %while.cond.i.i.i

while.cond.i.i.i:                                 ; preds = %while.cond.i.i.i, %if.end.i.i
  %lock.sroa.0.i.i.i.0.lock.sroa.0.i.i.i.0.lock.sroa.0.i.i.i.0.lock.sroa.0.i.i.0.lock.sroa.0.i.i.0.lock.sroa.0.i.0.lock.sroa.0.i.0.lock.sroa.0.0.lock.sroa.0.0.lock.sroa.0.0..i.i.i = load volatile ptr, ptr %lock.sroa.0.i.i.i, align 8, !tbaa !34
  %15 = tail call i32 asm sideeffect "atom.cas.acquire.sys.b32 $0,[$1],$2,$3;", "=r,l,r,r,~{memory}"(ptr %lock.sroa.0.i.i.i.0.lock.sroa.0.i.i.i.0.lock.sroa.0.i.i.i.0.lock.sroa.0.i.i.0.lock.sroa.0.i.i.0.lock.sroa.0.i.0.lock.sroa.0.i.0.lock.sroa.0.0.lock.sroa.0.0.lock.sroa.0.0..i.i.i, i32 0, i32 1) #7, !srcloc !36
  %cmp.i.i.i.i.i.i = icmp eq i32 %15, 0
  br i1 %cmp.i.i.i.i.i.i, label %_ZN4gsan12_GLOBAL__N_113acquireShadowEm.exit.i.i, label %while.cond.i.i.i, !llvm.loop !37

_ZN4gsan12_GLOBAL__N_113acquireShadowEm.exit.i.i: ; preds = %while.cond.i.i.i
  call void @llvm.lifetime.end.p0(ptr nonnull %lock.sroa.0.i.i.i)
  %read.sroa.0.0.copyload.i.i.i = load i16, ptr %14, align 4, !tbaa !23
  %read.sroa.4.0.arrayidx.sroa_idx.i.i.i = getelementptr inbounds nuw i8, ptr %14, i64 2
  %read.sroa.4.0.copyload.i.i.i = load i16, ptr %read.sroa.4.0.arrayidx.sroa_idx.i.i.i, align 2, !tbaa !25
  %bf.clear.i.i.i = and i16 %read.sroa.4.0.copyload.i.i.i, 4095
  %idxprom1.i.i.i = zext nneg i16 %bf.clear.i.i.i to i64
  %arrayidx2.i.i.i = getelementptr inbounds nuw [2 x i8], ptr %vectorClock.i.i.i, i64 %idxprom1.i.i.i
  %16 = load i16, ptr %arrayidx2.i.i.i, align 2, !tbaa !23
  %cmp4.not.i.i.i = icmp ult i16 %16, %read.sroa.0.0.copyload.i.i.i
  br i1 %cmp4.not.i.i.i, label %if.then.i.i.i, label %do.end.i.i.i

if.then.i.i.i:                                    ; preds = %_ZN4gsan12_GLOBAL__N_113acquireShadowEm.exit.i.i
  tail call void @__assertfail(ptr noundef nonnull @.str6, ptr noundef nonnull %cond.i.i.i.i, i32 noundef %line, ptr noundef nonnull @.str4, i64 noundef 1) #8
  br label %do.end.i.i.i

do.end.i.i.i:                                     ; preds = %if.then.i.i.i, %_ZN4gsan12_GLOBAL__N_113acquireShadowEm.exit.i.i
  %arrayidx.1.i.i.i = getelementptr inbounds nuw i8, ptr %14, i64 4
  %read.sroa.0.0.copyload.1.i.i.i = load i16, ptr %arrayidx.1.i.i.i, align 4, !tbaa !23
  %read.sroa.4.0.arrayidx.sroa_idx.1.i.i.i = getelementptr inbounds nuw i8, ptr %14, i64 6
  %read.sroa.4.0.copyload.1.i.i.i = load i16, ptr %read.sroa.4.0.arrayidx.sroa_idx.1.i.i.i, align 2, !tbaa !25
  %bf.clear.1.i.i.i = and i16 %read.sroa.4.0.copyload.1.i.i.i, 4095
  %idxprom1.1.i.i.i = zext nneg i16 %bf.clear.1.i.i.i to i64
  %arrayidx2.1.i.i.i = getelementptr inbounds nuw [2 x i8], ptr %vectorClock.i.i.i, i64 %idxprom1.1.i.i.i
  %17 = load i16, ptr %arrayidx2.1.i.i.i, align 2, !tbaa !23
  %cmp4.not.1.i.i.i = icmp ult i16 %17, %read.sroa.0.0.copyload.1.i.i.i
  br i1 %cmp4.not.1.i.i.i, label %if.then.1.i.i.i, label %do.end.1.i.i.i

if.then.1.i.i.i:                                  ; preds = %do.end.i.i.i
  tail call void @__assertfail(ptr noundef nonnull @.str6, ptr noundef nonnull %cond.i.i.i.i, i32 noundef %line, ptr noundef nonnull @.str4, i64 noundef 1) #8
  br label %do.end.1.i.i.i

do.end.1.i.i.i:                                   ; preds = %if.then.1.i.i.i, %do.end.i.i.i
  %arrayidx.2.i.i.i = getelementptr inbounds nuw i8, ptr %14, i64 8
  %read.sroa.0.0.copyload.2.i.i.i = load i16, ptr %arrayidx.2.i.i.i, align 4, !tbaa !23
  %read.sroa.4.0.arrayidx.sroa_idx.2.i.i.i = getelementptr inbounds nuw i8, ptr %14, i64 10
  %read.sroa.4.0.copyload.2.i.i.i = load i16, ptr %read.sroa.4.0.arrayidx.sroa_idx.2.i.i.i, align 2, !tbaa !25
  %bf.clear.2.i.i.i = and i16 %read.sroa.4.0.copyload.2.i.i.i, 4095
  %idxprom1.2.i.i.i = zext nneg i16 %bf.clear.2.i.i.i to i64
  %arrayidx2.2.i.i.i = getelementptr inbounds nuw [2 x i8], ptr %vectorClock.i.i.i, i64 %idxprom1.2.i.i.i
  %18 = load i16, ptr %arrayidx2.2.i.i.i, align 2, !tbaa !23
  %cmp4.not.2.i.i.i = icmp ult i16 %18, %read.sroa.0.0.copyload.2.i.i.i
  br i1 %cmp4.not.2.i.i.i, label %if.then.2.i.i.i, label %do.end.2.i.i.i

if.then.2.i.i.i:                                  ; preds = %do.end.1.i.i.i
  tail call void @__assertfail(ptr noundef nonnull @.str6, ptr noundef nonnull %cond.i.i.i.i, i32 noundef %line, ptr noundef nonnull @.str4, i64 noundef 1) #8
  br label %do.end.2.i.i.i

do.end.2.i.i.i:                                   ; preds = %if.then.2.i.i.i, %do.end.1.i.i.i
  %arrayidx.3.i.i.i = getelementptr inbounds nuw i8, ptr %14, i64 12
  %read.sroa.0.0.copyload.3.i.i.i = load i16, ptr %arrayidx.3.i.i.i, align 4, !tbaa !23
  %read.sroa.4.0.arrayidx.sroa_idx.3.i.i.i = getelementptr inbounds nuw i8, ptr %14, i64 14
  %read.sroa.4.0.copyload.3.i.i.i = load i16, ptr %read.sroa.4.0.arrayidx.sroa_idx.3.i.i.i, align 2, !tbaa !25
  %bf.clear.3.i.i.i = and i16 %read.sroa.4.0.copyload.3.i.i.i, 4095
  %idxprom1.3.i.i.i = zext nneg i16 %bf.clear.3.i.i.i to i64
  %arrayidx2.3.i.i.i = getelementptr inbounds nuw [2 x i8], ptr %vectorClock.i.i.i, i64 %idxprom1.3.i.i.i
  %19 = load i16, ptr %arrayidx2.3.i.i.i, align 2, !tbaa !23
  %cmp4.not.3.i.i.i = icmp ult i16 %19, %read.sroa.0.0.copyload.3.i.i.i
  br i1 %cmp4.not.3.i.i.i, label %if.then.3.i.i.i, label %do.end.3.i.i.i

if.then.3.i.i.i:                                  ; preds = %do.end.2.i.i.i
  tail call void @__assertfail(ptr noundef nonnull @.str6, ptr noundef nonnull %cond.i.i.i.i, i32 noundef %line, ptr noundef nonnull @.str4, i64 noundef 1) #8
  br label %do.end.3.i.i.i

do.end.3.i.i.i:                                   ; preds = %if.then.3.i.i.i, %do.end.2.i.i.i
  %writeClock.i.i.i = getelementptr inbounds nuw i8, ptr %14, i64 16
  %write.sroa.0.0.copyload.i.i.i = load i16, ptr %writeClock.i.i.i, align 4, !tbaa !23
  %write.sroa.4.0.writeClock.sroa_idx.i.i.i = getelementptr inbounds nuw i8, ptr %14, i64 18
  %write.sroa.4.0.copyload.i.i.i = load i16, ptr %write.sroa.4.0.writeClock.sroa_idx.i.i.i, align 2, !tbaa !25
  %bf.clear8.i.i.i = and i16 %write.sroa.4.0.copyload.i.i.i, 4095
  %idxprom9.i.i.i = zext nneg i16 %bf.clear8.i.i.i to i64
  %arrayidx10.i.i.i = getelementptr inbounds nuw [2 x i8], ptr %vectorClock.i.i.i, i64 %idxprom9.i.i.i
  %20 = load i16, ptr %arrayidx10.i.i.i, align 2, !tbaa !23
  %cmp14.not.i.i.i = icmp ult i16 %20, %write.sroa.0.0.copyload.i.i.i
  br i1 %cmp14.not.i.i.i, label %if.then15.i.i.i, label %_ZN4gsan12_GLOBAL__N_17doWriteEPNS_11ThreadStateEPNS_10ShadowCellENS_8LocationE.exit.i.i

if.then15.i.i.i:                                  ; preds = %do.end.3.i.i.i
  tail call void @__assertfail(ptr noundef nonnull @.str7, ptr noundef nonnull %cond.i.i.i.i, i32 noundef %line, ptr noundef nonnull @.str4, i64 noundef 1) #8
  br label %_ZN4gsan12_GLOBAL__N_17doWriteEPNS_11ThreadStateEPNS_10ShadowCellENS_8LocationE.exit.i.i

_ZN4gsan12_GLOBAL__N_17doWriteEPNS_11ThreadStateEPNS_10ShadowCellENS_8LocationE.exit.i.i: ; preds = %if.then15.i.i.i, %do.end.3.i.i.i
  %21 = load i16, ptr %threadId22.i.i.i, align 4, !tbaa !23
  %idxprom24.i.i.i = zext i16 %21 to i64
  %arrayidx25.i.i.i = getelementptr inbounds nuw [2 x i8], ptr %vectorClock.i.i.i, i64 %idxprom24.i.i.i
  %22 = load i16, ptr %arrayidx25.i.i.i, align 2, !tbaa !23
  %bf.value.i.i.i = and i16 %21, 4095
  store i16 %22, ptr %writeClock.i.i.i, align 4, !tbaa !23
  store i16 %bf.value.i.i.i, ptr %write.sroa.4.0.writeClock.sroa_idx.i.i.i, align 2, !tbaa !25
  call void @llvm.lifetime.start.p0(ptr nonnull %lock.sroa.0.i27.i.i)
  store ptr %lock1.i.i.i, ptr %lock.sroa.0.i27.i.i, align 8, !tbaa !26
  %lock.sroa.0.i27.i.i.0.lock.sroa.0.i27.i.i.0.lock.sroa.0.i27.i.i.0.lock.sroa.0.i27.i.0.lock.sroa.0.i27.i.0.lock.sroa.0.i27.0.lock.sroa.0.i27.0.lock.sroa.0.0.lock.sroa.0.0.lock.sroa.0.0..i29.i.i = load volatile ptr, ptr %lock.sroa.0.i27.i.i, align 8, !tbaa !34
  tail call void asm sideeffect "st.release.sys.b32 [$0], $1;", "l,r,~{memory}"(ptr %lock.sroa.0.i27.i.i.0.lock.sroa.0.i27.i.i.0.lock.sroa.0.i27.i.i.0.lock.sroa.0.i27.i.0.lock.sroa.0.i27.i.0.lock.sroa.0.i27.0.lock.sroa.0.i27.0.lock.sroa.0.0.lock.sroa.0.0.lock.sroa.0.0..i29.i.i, i32 0) #7, !srcloc !44
  call void @llvm.lifetime.end.p0(ptr nonnull %lock.sroa.0.i27.i.i)
  br label %for.inc.i.i

for.inc.i.i:                                      ; preds = %_ZN4gsan12_GLOBAL__N_17doWriteEPNS_11ThreadStateEPNS_10ShadowCellENS_8LocationE.exit.i.i, %for.body.i.i
  %add8.i.i = add i64 %addr.031.i.i, 4
  %cmp.i.i = icmp ult i64 %add8.i.i, %add.i.i.i
  br i1 %cmp.i.i, label %for.body.i.i, label %_ZN4gsan12_GLOBAL__N_110writeRangeEPNS_11ThreadStateEmiNS_8LocationE.exit.i, !llvm.loop !49

_ZN4gsan12_GLOBAL__N_110writeRangeEPNS_11ThreadStateEmiNS_8LocationE.exit.i: ; preds = %for.inc.i.i, %_ZN4gsan12_GLOBAL__N_117rwLockAcquireReadERj.exit.i.i
  call void @llvm.lifetime.start.p0(ptr nonnull %atom.sroa.0.i20.i.i)
  store ptr %lock.i.i, ptr %atom.sroa.0.i20.i.i, align 8, !tbaa !26
  %atom.sroa.0.i20.i.i.0.atom.sroa.0.i20.i.i.0.atom.sroa.0.i20.i.i.0.atom.sroa.0.i20.i.0.atom.sroa.0.i20.i.0.atom.sroa.0.i20.0.atom.sroa.0.i20.0.atom.sroa.0.0.atom.sroa.0.0.atom.sroa.0.0..i21.i.i = load volatile ptr, ptr %atom.sroa.0.i20.i.i, align 8, !tbaa !28
  %23 = tail call i32 asm sideeffect "atom.add.relaxed.cta.u32 $0,[$1],$2;", "=r,l,r,~{memory}"(ptr %atom.sroa.0.i20.i.i.0.atom.sroa.0.i20.i.i.0.atom.sroa.0.i20.i.i.0.atom.sroa.0.i20.i.0.atom.sroa.0.i20.i.0.atom.sroa.0.i20.0.atom.sroa.0.i20.0.atom.sroa.0.0.atom.sroa.0.0.atom.sroa.0.0..i21.i.i, i32 -1) #7, !srcloc !46
  call void @llvm.lifetime.end.p0(ptr nonnull %atom.sroa.0.i20.i.i)
  br label %if.end.i

if.end.i:                                         ; preds = %_ZN4gsan12_GLOBAL__N_110writeRangeEPNS_11ThreadStateEmiNS_8LocationE.exit.i, %for.body.i
  %inc.i = add nuw nsw i32 %i.010.i, 1
  %exitcond.not.i = icmp eq i32 %inc.i, %numElems
  br i1 %exitcond.not.i, label %_ZN4gsan12_GLOBAL__N_111tensorStoreEPNS_11ThreadStateEPKciiNS_8LocationE.exit, label %for.body.i, !llvm.loop !50

_ZN4gsan12_GLOBAL__N_111tensorStoreEPNS_11ThreadStateEPKciiNS_8LocationE.exit: ; preds = %if.end.i, %_ZN4gsan12_GLOBAL__N_114getThreadStateEPNS_11GlobalStateE.exit
  ret void
}

; Function Attrs: convergent nounwind denormal_fpenv(float: preservesign)
declare dso_local void @__assertfail(ptr noundef, ptr noundef, i32 noundef, ptr noundef, i64 noundef) local_unnamed_addr #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare noundef range(i32 0, 1024) i32 @llvm.nvvm.read.ptx.sreg.tid.x() #4

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.fshl.i32(i32, i32, i32) #5

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn denormal_fpenv(float: preservesign) memory(argmem: read) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_80" "target-features"="+ptx84,+sm_80" "uniform-work-group-size" }
attributes #1 = { convergent mustprogress nounwind denormal_fpenv(float: preservesign) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_80" "target-features"="+ptx84,+sm_80" "uniform-work-group-size" }
attributes #2 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { convergent nounwind denormal_fpenv(float: preservesign) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_80" "target-features"="+ptx84,+sm_80" "uniform-work-group-size" }
attributes #4 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #5 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #6 = { convergent nounwind memory(none) }
attributes #7 = { convergent nounwind }
attributes #8 = { convergent nounwind "uniform-work-group-size" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}
!llvm.errno.tbaa = !{!3}

!0 = !{i32 4, !"nvvm-reflect-ftz", i32 1}
!1 = !{i32 7, !"frame-pointer", i32 2}
!2 = !{!"clang version 23.0.0git (https://github.com/llvm/llvm-project.git 7f77ca0dbda4abbf9af06537b2c475f20ccd6007)"}
!3 = !{!4, !4, i64 0}
!4 = !{!"int", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C++ TBAA"}
!7 = !{!8, !9, i64 0}
!8 = !{!"_ZTSN4gsan8LocationE", !9, i64 0, !4, i64 8}
!9 = !{!"p1 omnipotent char", !10, i64 0}
!10 = !{!"any pointer", !5, i64 0}
!11 = !{i64 2187}
!12 = !{!13, !15, i64 24}
!13 = !{!"_ZTSN4gsan11GlobalStateE", !14, i64 0, !14, i64 8, !4, i64 16, !15, i64 20, !15, i64 22, !15, i64 24, !15, i64 26}
!14 = !{!"long", !5, i64 0}
!15 = !{!"short", !5, i64 0}
!16 = !{!13, !15, i64 26}
!17 = !{!18, !18, i64 0}
!18 = !{!"p1 _ZTSN4gsan11GlobalStateE", !10, i64 0}
!19 = !{!13, !14, i64 0}
!20 = !{!14, !14, i64 0}
!21 = !{!13, !14, i64 8}
!22 = !{!13, !15, i64 20}
!23 = !{!15, !15, i64 0}
!24 = !{i64 12375969}
!25 = !{!5, !5, i64 0}
!26 = !{!27, !27, i64 0}
!27 = !{!"p1 int", !10, i64 0}
!28 = !{!29, !27, i64 0}
!29 = !{!"_ZTSN4cuda3std3__48__detail6__host26__cxx_atomic_ref_base_implIjLi2EEE", !27, i64 0}
!30 = !{i64 12313768}
!31 = !{i64 12288983}
!32 = distinct !{!32, !33}
!33 = !{!"llvm.loop.mustprogress"}
!34 = !{!35, !27, i64 0}
!35 = !{!"_ZTSN4cuda3std3__48__detail6__host26__cxx_atomic_ref_base_implIjLi0EEE", !27, i64 0}
!36 = !{i64 12472658}
!37 = distinct !{!37, !33}
!38 = !{!39, !4, i64 20}
!39 = !{!"_ZTSN4gsan10ShadowCellE", !5, i64 0, !40, i64 16, !4, i64 20, !4, i64 24}
!40 = !{!"_ZTSN4gsan11ScalarClockE", !15, i64 0, !15, i64 2, !41, i64 3}
!41 = !{!"_ZTSN4gsan11AtomicScopeE", !5, i64 0}
!42 = !{i64 12314046}
!43 = !{!13, !4, i64 16}
!44 = !{i64 12469338}
!45 = distinct !{!45, !33}
!46 = !{i64 12331895}
!47 = distinct !{!47, !33}
!48 = !{i64 2286}
!49 = distinct !{!49, !33}
!50 = distinct !{!50, !33}
