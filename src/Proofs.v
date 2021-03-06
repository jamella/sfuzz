
(* Require Import QArith. *)

Require Import Arith.
Require Import CaseNotation.

Notation "x :: l" := (cons x l) (at level 60, right associativity).
Notation "[ ]" := nil.
Notation "[ x ; .. ; y ]" := (cons x .. (cons y nil) ..).


Inductive simList {X:Type} : nat -> list X -> list X -> Prop :=
  | simL_cons h t1 t2  : forall d, simList d t1 t2 
                         -> simList d (cons h t1) (cons h t2)
  | simL_consL h l1 l2 : forall d, simList d l1 l2
                         -> simList (S d) (cons h l1) l2
  | simL_consR h l1 l2 : forall d, simList d l1 l2
                         -> simList (S d) l1 (cons h l2)
  | simL_eq l1 l2      : forall d, eq l1 l2 -> simList d l1 l2.

Lemma simListWeak : forall (X : Type) d (l1 l2 : list X),
  simList d l1 l2 -> simList (S d) l1 l2.
Proof. intros X d l1 l2 H.
  induction H; try (constructor; apply IHsimList).
  Case "eq". constructor. apply H.
Qed.

Example simEx1 : simList 1 [1;2] [2].
Proof. constructor. apply simL_eq. reflexivity. Qed.

Example simEx2 : simList 1 [1;2;3;4] [1;3;4].
Proof. apply simL_cons. 
  apply simL_consL. apply simL_eq. reflexivity. Qed.

Example simEx3 : simList 2 [2] [1].
Proof. constructor. constructor. constructor. reflexivity. Qed.

Inductive all {X : Type} (P : X -> Prop) : list X -> Prop :=
  | all_nil : all P []
  | all_cons x l : P x -> all P l -> all P (x :: l).


Inductive simNat : nat -> nat -> nat -> Prop :=
  | simN_S n1 n2    : forall d, simNat d n1 n2 -> simNat d (S n1) (S n2)
  | simN_l n1 n2    : forall d, simNat d n1 n2 -> simNat (S d) (S n1) n2
  | simN_r n1 n2    : forall d, simNat d n1 n2 -> simNat (S d) n1 (S n2)
  | simN_eq n1 n2   : forall d, eq_nat n1 n2 -> simNat d n1 n2.

Lemma simNatPlus : forall (d n s1 s2 : nat),
  simNat d s1 s2 -> simNat d (n+s1) (n+s2).
Proof. intros d n s1 s2 H. induction n as [| n' IHn].
  simpl. apply H.
  simpl. constructor. apply IHn.
Qed.

Lemma simNatWeak : forall d n1 n2,
  simNat d n1 n2 -> simNat (S d) n1 n2.
Proof. intros d n1 n2 H.
  induction H; try (constructor; apply IHsimNat).
  Case "eq". constructor. apply H.
Qed.


Fixpoint sumList (l : list nat) : nat :=
  match l with
    | [] => 0
    | n :: l' => n + sumList l'
  end.

Example sumListEx1 : eq_nat 10 (sumList [1;2;3;4]).
Proof. reflexivity. Qed.



Lemma foo : forall (Arg Arg' : list nat) (d:nat),
  simList d Arg Arg' ->
  all (fun x => x <= 1) Arg ->
  all (fun x => x <= 1) Arg' ->
  simNat d (sumList Arg) (sumList Arg').
Proof. intros Arg Arg' d HListSim HArgClip HArg'Clip.
induction HListSim as [h l1 l2 d HListSim' IHLS|
                       h l1 l2 d HListSim' IHLS|
                       h l1 l2 d HListSim' IHLS|
                       l1 l2 d eq].
  Case "cons".
    simpl. apply simNatPlus. apply IHLS.
    inversion HArgClip as [ | x l HLT1 HLTTail].
      apply HLTTail.
    inversion HArg'Clip as [asdf | x l HLT1 HLTTail].
      apply HLTTail.
  Case "consL".
    inversion HArgClip as [asdf | x l HLT1 HLTTail].
    inversion HLT1 as [ | x' HLT0].
    SCase "head is 1".
      simpl. constructor. apply IHLS.
      apply HLTTail. apply HArg'Clip.
    SCase "head is 0".
      inversion HLT0.
      simpl. apply simNatWeak. apply IHLS.
        apply HLTTail. apply HArg'Clip.
  Case "consR".
    inversion HArg'Clip as [ | x l HLT1 HLTTail].
    inversion HLT1 as [ | x' HLT0].
    SCase "head is 1".
      simpl. constructor. apply IHLS.
      apply HArgClip. apply HLTTail.
    SCase "head is 0".
      inversion HLT0.
      simpl. apply simNatWeak. apply IHLS.
        apply HArgClip. apply HLTTail.
  Case "eq".
    rewrite eq. constructor. apply eq_nat_refl.
Qed.
    





