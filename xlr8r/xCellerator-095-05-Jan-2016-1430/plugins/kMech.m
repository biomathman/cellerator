(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



BeginPackage["kMech`"];

kMech::usage=
"kMech translates complicated enzymatic reactions and inhibition models using elementary reactions provided in xCellerator.";

Begin["`Private`"];
$KmechVersion = "1.01";
End[];
(* Name Concatenation for Enzyme-Substrates Complexes *)


NC[V_Symbol]:= ToExpression[StringJoin["$Complex$",ToString[V],"$"]];
NC[V__,W_Symbol]:= ToExpression[StringJoin[ToString[NC[V]],ToString[W],"$"]];


(* Name Concatenation for Multiple Inhibitors Reaction *)

 
NC2[V_]:=ToExpression["$Complex$"<>ToString[V]<>"$"];
NC2[V__,W_]:=ToExpression[ToString[NC2[V]]<>ToString[W]];


(* Name Concatenation for Initial Condition *)

InitialCondition[varName_]=ToExpression[ToString[varName]<>"[0]\[Equal]0"];
InitialConditionGenerator[varList_]:=Map[InitialCondition,varList];



(* Kf, Kr Estimation for Mass Action Model *)

Kf[Km_,Kcat_,Lamda_]:=N[(Lamda*Kcat)/Km];

Kf2S[Km1_,Km2_,Kcat_,Lamda_]:=N[(Lamda*Kcat)/(Km1 Km2)];

Kf3S[Km1_,Km2_,Km3_,Kcat_,Lamda_]:=N[(Lamda*Kcat)/(Km1 Km2 Km3)];

Kr[Kcat_,Lamda_]:=Max[0,N[(Lamda-1)*Kcat]];


(* Kfi,Kri Estimation for Inhibition model *)

Kfi[Km_,Kcat_,Lamda_,Omega_]:=N[Omega*(Lamda*Kcat)/Km];
Kri[Km_,Kcat_,Lamda_,Omega_,Ki_]:=N[Omega*(Lamda*Kcat)/Km*Ki];


(* Models of Inhibition: *)

(* Competitive Inhibition *)

Enz[

\!\(\*OverscriptBox[\({S_} \[RightArrowLeftArrow] {P_}\), \(En_\)]\),UniUni[kf_,kr_,k_],CI[inh_,kfi_,kri_]]:={{S+En\[RightArrowLeftArrow]NC[S,En], kf, kr},{NC[S,En]\[ShortRightArrow]En+P,k},{En+inh\[RightArrowLeftArrow]NC[En,inh],kfi,kri}} ;


(* Non-Competitive Inhibition,assume that inhibitor will not interfer substrate binding on enzyme, means substrate still can bing Enzyme-Inhibitor complex *)

Enz[

\!\(\*OverscriptBox[\({S_} \[RightArrowLeftArrow] {P_}\), \(En_\)]\),UniUni[kf_,kr_,k_],NCI[inh_,kfi_,kri_]]:={{S+En\[RightArrowLeftArrow]NC[S,En], kf, kr},{NC[S,En]\[ShortRightArrow]En+P,k},{En+inh\[RightArrowLeftArrow]NC[En,inh],kfi,kri},{NC[S,En]+inh\[RightArrowLeftArrow]NC[S,En,inh],kfi,kri},{S+NC[En,inh]\[RightArrowLeftArrow]NC[S,En,inh],kf,kr}};


(* Non-Competitive Inhibition, Enzyme-Inhibitor complex has residual enzyme activity, residualRate = 0 to 1 *)

Enz[

\!\(\*OverscriptBox[\({S_} \[RightArrowLeftArrow] {P_}\), \(En_\)]\),UniUni[kf_,kr_,k_],NCI[inh_,kfi_,kri_,residualRate_]]:={{S+En\[RightArrowLeftArrow]NC[S,En], kf, kr},{NC[S,En]\[ShortRightArrow]En+P,k},{En+inh\[RightArrowLeftArrow]NC[En, inh],kfi,kri},{NC[S,En]+inh\[RightArrowLeftArrow]NC[S,En,inh],kfi,kri},{S+NC[En,inh]\[RightArrowLeftArrow]NC[S,En,inh],kf,kr},{NC[S,En,inh]\[ShortRightArrow]NC[En,inh]+P,residualRate*k}};     


(* Un-Competitive Inhibition *)

Enz[

\!\(\*OverscriptBox[\({S_} \[RightArrowLeftArrow] {P_}\), \(En_\)]\),UniUni[kf_,kr_,k_],UCI[inh_,kfi_,kri_]]:={ {S+En\[RightArrowLeftArrow]NC[S,En], kf, kr},{NC[S,En]\[ShortRightArrow]En+P,k},{NC[S,En]+inh\[RightArrowLeftArrow]NC[S,En,inh],kfi,kri}};


(* Reaction Schema Translations for Multiple Substrates Reaction *)
(* Using Cellerator reactions as building blocks for the complicated enzymatic reactions *)

Enz[

\!\(\*OverscriptBox[\({S_} \[RightArrowLeftArrow] {P_}\), \(En_\)]\),UniUni[kf_,kr_,k_]]:={{S+En\[RightArrowLeftArrow]NC[S,En], kf, kr},{NC[S,En]\[ShortRightArrow]En+P,k}} ;

(* UniBi and BiUni Models *)

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_}\), \(En_\)]\),BiUni[kf_,kr_,k_]]:={{S1+S2+En\[RightArrowLeftArrow]NC[En,S1,S2],kf,kr},{NC[En,S1,S2]\[ShortRightArrow]En+P1,k}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_}\), \(En_\)]\),OrderedBiUni[kf1_,kr1_,kf2_,kr2_,k_]]:={{S1+En\[RightArrowLeftArrow]NC[En,S1],kf1,kr1},{S2+NC[En,S1]\[RightArrowLeftArrow]NC[En,S1,S2],kf2,kr2},{NC[En,S1,S2]\[ShortRightArrow]En+P1,k}};

Enz[

\!\(\*OverscriptBox[\({S1_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_\)]\),UniBi[kf_,kr_,k_]]:={{S1+En\[RightArrowLeftArrow]NC[En,S1],kf,kr},{NC[En,S1]\[ShortRightArrow]En+P1+P2,k}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_}\), \(En_\)]\),BiUni[kf_,kr_,k_],CI[Inh_,kfi_,kri_]]:={{S1+S2+En\[RightArrowLeftArrow]NC[En,S1,S2],kf,kr},{NC[En,S1,S2]\[ShortRightArrow]En+P1,k},{En+Inh\[RightArrowLeftArrow]NC[En,Inh],kfi,kri}};

Enz[

\!\(\*OverscriptBox[\({S1_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_\)]\),UniBi[kf_,kr_,k_],CI[Inh_,kfi_,kri_]]:={{S1+En\[RightArrowLeftArrow]NC[En,S1],kf,kr},{NC[En,S1]\[ShortRightArrow]En+P1+P2,k},{En+Inh\[RightArrowLeftArrow]NC[En,Inh],kfi,kri}};

Enz[

\!\(\*OverscriptBox[\({S1_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_\)]\),UniBi[kf_,kr_,k_],CI[Inh_,kfi_,kri_],NCI[Inhn_,kfin_,krin_]]:={{S1+En\[RightArrowLeftArrow]NC[En,S1],kf,kr},{NC[En,S1]\[ShortRightArrow]En+P1+P2,k},{En+Inh\[RightArrowLeftArrow]NC[En,Inh],kfi,kri},{En+Inhn\[RightArrowLeftArrow]NC[En,Inhn],kfin,krin},{NC[En,S1]+Inhn\[RightArrowLeftArrow]NC[En,S1,Inhn],kfin,krin},{S1+NC[En,Inhn]\[RightArrowLeftArrow]NC[En,S1,Inhn],kf,kr}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_}\), \(En_\)]\),BiUni[kf_,kr_,k_],CI[Inh_,kfi_,kri_],NCI[Inhn_,kfin_,krin_]]:={{S1+S2+En\[RightArrowLeftArrow]NC[En,S1,S2],kf,kr},{NC[En,S1,S2]\[ShortRightArrow]En+P1,k},{En+Inh\[RightArrowLeftArrow]NC[En,Inh],kfi,kri},{En+Inhn\[RightArrowLeftArrow]NC[En,Inhn],kfin,krin},{NC[En,S1,S2]+Inhn\[RightArrowLeftArrow]NC[En,S1,S2,Inhn],kfin,krin},{S1+S2+NC[En,Inhn]\[RightArrowLeftArrow]NC[En,S1,S2,Inhn],kf,kr}};


(* Bi Bi or Sequential Model *)

(* S1+S2+En<->ES1S2(X)->En+P1+P2 kf,kr,k *) 

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_\)]\),BiBi[kf_,kr_,k_]]:={{S1+S2+En\[RightArrowLeftArrow]NC[En,S1,S2],kf,kr},{NC[En,S1,S2]\[ShortRightArrow]En+P1+P2,k}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_\)]\),OrderedBiBi[kf1_,kr1_,kf2_,kr2_,k_]]:={{S1+En\[RightArrowLeftArrow]NC[En,S1],kf1,kr1},{S2+NC[En,S1]\[RightArrowLeftArrow]NC[En,S1,S2],kf2,kr2},
{NC[En,S1,S2]\[ShortRightArrow]NC[En,S2]+P1,k},{NC[En,S2]\[ShortRightArrow]En+P2,k}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_\)]\),OrderedBiBi[kf1_,kr1_,kf2_,kr2_,k_],CI[Inh_,kfi_,kri_]]:={{S1+En\[RightArrowLeftArrow]NC[En,S1],kf1,kr1},{S2+NC[En,S1]\[RightArrowLeftArrow]NC[En,S1,S2],kf2,kr2},
{NC[En,S1,S2]\[ShortRightArrow]NC[En,S2]+P1,k},{NC[En,S2]\[ShortRightArrow]En+P2,k},{En+Inh\[RightArrowLeftArrow]NC[En,Inh],kfi,kri}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_\)]\),OrderedBiBi[kf1_,kr1_,kf2_,kr2_,k_],CI1[Inh1_,kfi1_,kri1_],CI2[Inh2_,kfi2_,kri2_]]:={{S1+En\[RightArrowLeftArrow]NC[En,S1],kf1,kr1},{S2+NC[En,S1]\[RightArrowLeftArrow]NC[En,S1,S2],kf2,kr2},
{NC[En,S1,S2]\[ShortRightArrow]NC[En,S2]+P1,k},{NC[En,S2]\[ShortRightArrow]En+P2,k},{En+Inh1\[RightArrowLeftArrow]NC[En,Inh1],kfi1,kri1},{En+Inh2\[RightArrowLeftArrow]NC[En,Inh2],kfi1,kri2}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_\)]\),RandomBiBi[kf1_,kr1_,kf2_,kr2_,k_]]:={{S1+En\[RightArrowLeftArrow]NC[En,S1],kf1,kr1},{S2+En\[RightArrowLeftArrow]NC[En,S2],kf2,kr2},{S2+NC[En,S1]\[RightArrowLeftArrow]NC[En,S1,S2],kf2,kr2},{S1+NC[En,S2]\[RightArrowLeftArrow]NC[En,S1,S2],kf1,kr1},
{NC[En,S1,S2]\[ShortRightArrow]En+P1+P2,k}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_\)]\),RandomBiBi[kf1_,kr1_,kf2_,kr2_,k_],CI[Inh_,kfi_,kri_]]:={{S1+En\[RightArrowLeftArrow]NC[En,S1],kf1,kr1},{S2+En\[RightArrowLeftArrow]NC[En,S2],kf2,kr2},{S2+NC[En,S1]\[RightArrowLeftArrow]NC[En,S1,S2],kf2,kr2},{S1+NC[En,S2]\[RightArrowLeftArrow]NC[En,S1,S2],kf1,kr1},
{NC[En,S1,S2]\[ShortRightArrow]En+P1+P2,k},{En+Inh\[RightArrowLeftArrow]NC[En,Inh],kfi,kri}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_\)]\),RandomBiBi[kf1_,kr1_,kf2_,kr2_,k_],CI1[Inh1_,kfi1_,kri1_],CI2[Inh2_,kfi2_,kri2_]]:={{S1+En\[RightArrowLeftArrow]NC[En,S1],kf1,kr1},{S2+En\[RightArrowLeftArrow]NC[En,S2],kf2,kr2},{S2+NC[En,S1]\[RightArrowLeftArrow]NC[En,S1,S2],kf2,kr2},{S1+NC[En,S2]\[RightArrowLeftArrow]NC[En,S1,S2],kf1,kr1},
{NC[En,S1,S2]\[ShortRightArrow]En+P1+P2,k},{En+Inh1\[RightArrowLeftArrow]NC[En,Inh1],kfi1,kri1},{En+Inh2\[RightArrowLeftArrow]NC[En,Inh2],kfi1,kri2}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_\)]\),RandomBiBi[kf1_,kr1_,kf2_,kr2_,k_],NCI[Inh_,kfi_,kri_]]:={{S1+En\[RightArrowLeftArrow]NC[En,S1],kf1,kr1},{S2+En\[RightArrowLeftArrow]NC[En,S2],kf2,kr2},{S2+NC[En,S1]\[RightArrowLeftArrow]NC[En,S1,S2],kf2,kr2},{S1+NC[En,S2]\[RightArrowLeftArrow]NC[En,S1,S2],kf1,kr1},
{NC[En,S1,S2]\[ShortRightArrow]En+P1+P2,k},{En+Inh\[RightArrowLeftArrow]NC[En,Inh],kfi,kri},{NC[En,S1]+Inh\[RightArrowLeftArrow]NC[En,S1,Inh],kfi,kri},{NC[En,S2]+Inh\[RightArrowLeftArrow]NC[En,S2,Inh],kfi,kri},{NC[En,S1,S2]+Inh\[RightArrowLeftArrow]NC[En,S1,S2,Inh],kfi,kri}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_\)]\),RandomBiBi[kf1_,kr1_,kf2_,kr2_,k_],NCI1[Inh1_,kfi1_,kri1_],NCI2[Inh2_,kfi2_,kri2_]]:={{S1+En\[RightArrowLeftArrow]NC[En,S1],kf1,kr1},{S2+En\[RightArrowLeftArrow]NC[En,S2],kf2,kr2},{S2+NC[En,S1]\[RightArrowLeftArrow]NC[En,S1,S2],kf2,kr2},{S1+NC[En,S2]\[RightArrowLeftArrow]NC[En,S1,S2],kf1,kr1},
{NC[En,S1,S2]\[ShortRightArrow]En+P1+P2,k},{En+Inh1\[RightArrowLeftArrow]NC[En,Inh1],kfi1,kri1},{NC[En,S1]+Inh1\[RightArrowLeftArrow]NC[En,S1,Inh1],kfi1,kri1},{NC[En,S2]+Inh1\[RightArrowLeftArrow]NC[En,S2,Inh1],kfi1,kri1},{NC[En,S1,S2]+Inh1\[RightArrowLeftArrow]NC[En,S1,S2,Inh1],kfi1,kri1},{En+Inh2\[RightArrowLeftArrow]NC[En,Inh2],kfi2,kri2},{NC[En,S1]+Inh2\[RightArrowLeftArrow]NC[En,S1,Inh2],kfi2,kri2},{NC[En,S2]+Inh2\[RightArrowLeftArrow]NC[En,S2,Inh2],kfi2,kri2},{NC[En,S1,S2]+Inh2\[RightArrowLeftArrow]NC[En,S1,S2,Inh2],kfi2,kri2}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_\)]\),BiBi[kf_,kr_,k_],CI[Inh_,kfi_,kri_]]:={{S1+S2+En\[RightArrowLeftArrow]NC[En,S1,S2],kf,kr},{NC[En,S1,S2]\[ShortRightArrow]En+P1+P2,k},{En+Inh\[RightArrowLeftArrow]NC[En,Inh],kfi,kri}};


(* More than two substrates and two products *)

Enz[

\!\(\*OverscriptBox[\({S__} \[RightArrowLeftArrow] {P__}\), \(En_\)]\),MulS[kf_,kr_,k_]]:={{Plus[S]+En\[RightArrowLeftArrow]NC[En,S],kf,kr},{NC[En,S]\[ShortRightArrow]En+Plus[P],k}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_, P3_}\), \(En_\)]\),BiTer[kf_,kr_,k_]]:={{S1+S2+En\[RightArrowLeftArrow]NC[En,S1,S2],kf,kr},{NC[En,S1,S2]\[ShortRightArrow]En+P1+P2+P3,k}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_, S3_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_\)]\),TerBi[kf_,kr_,k_]]:={{S1+S2+S3+En\[RightArrowLeftArrow]NC[En,S1,S2,S3],kf,kr},{NC[En,S1,S2,S3]\[ShortRightArrow]En+P1+P2,k}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_, S3_} \[RightArrowLeftArrow] {P1_, P2_, P3_}\), \(En_\)]\),TerTer[kf_,kr_,k_]]:={{S1+S2+S3+En\[RightArrowLeftArrow]NC[En,S1,S2,S3],kf,kr},{NC[En,S1,S2,S3]\[ShortRightArrow]En+P1+P2+P3,k}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_, S3_} \[RightArrowLeftArrow] {P1_, P2_, P3_}\), \(En_\)]\),TerTer[kf_,kr_,k_],CI[Inh_,kfi_,kri_]]:={{S1+S2+S3+En\[RightArrowLeftArrow]NC[En,S1,S2,S3],kf,kr},{NC[En,S1,S2,S3]\[ShortRightArrow]En+P1+P2+P3,k},{En+Inh\[RightArrowLeftArrow]NC[En,Inh],kfi,kri}};

(* Ping Pong Model *)
(* A+En<->(EnA) ->Enx+C,kfA,krA,k1,En *)
(* Enx+B<->EnxB ->E+F,kfB,krB,k2,En *)
(* x is a transfered functional group *)

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_, Enx_\)]\),PingPong[kf1_,kr1_,k1_,kf2_,kr2_,k2_]]:={{S1+En\[RightArrowLeftArrow]NC[S1,En], kf1, kr1},{NC[S1,En]\[ShortRightArrow]Enx+P1,k1},
{S2+Enx\[RightArrowLeftArrow]NC[S2,Enx], kf2, kr2},{NC[S2,Enx]\[ShortRightArrow]En+P2,k2}};


(* PingPong Model with Non-Competitive Inhibition, 100% inhibition when saturated with inhibitor *)

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_, Enx_\)]\),PingPong[kf1_,kr1_,k1_,kf2_,kr2_,k2_],NCI[Inh_,kfi_,kri_]]:={{S1+En\[RightArrowLeftArrow]NC[S1,En], kf1, kr1},{NC[S1,En]\[ShortRightArrow]Enx+P1,k1},
{S2+Enx\[RightArrowLeftArrow]NC[S2,Enx], kf2, kr2},{NC[S2,Enx]\[ShortRightArrow]En+P2,k2},
{En+Inh\[RightArrowLeftArrow]NC[En,Inh],kfi,kri},{NC[S1,En]+Inh\[RightArrowLeftArrow]NC[S1,En,Inh],kfi,kri},
{Enx+Inh\[RightArrowLeftArrow]NC[Enx,Inh],kfi,kri},{NC[S2,Enx]+Inh\[RightArrowLeftArrow]NC[S2,Enx,Inh],kfi,kri},{S1+NC[En,Inh]\[RightArrowLeftArrow]NC[S1,En,Inh],kf1,kr1},{S2+NC[Enx,Inh]\[RightArrowLeftArrow]NC[S2,Enx,Inh],kf2,kr2}};


(* PingPong Model with Non-Competitive Inhibition, has residual activity when saturated with inhibitor *)
(* Inhibitor binds enzyme causing conformation change, 2 substrates moving apart,reduce the catalytic activity, but not 100% inhibition *)
(* k2: kcat without inhibitor, residualRate: residual enzyme activity (0 to 1) with saturated inhibitor *)

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_, Enx_\)]\),PingPong[kf1_,kr1_,k1_,kf2_,kr2_,k2_],NCI[Inh_,kfi_,kri_,residualRate_]]:={{S1+En\[RightArrowLeftArrow]NC[S1,En], kf1, kr1},{NC[S1,En]\[ShortRightArrow]Enx+P1, k1},
{S2+Enx\[RightArrowLeftArrow]NC[S2,Enx], kf2, kr2},{NC[S2,Enx]\[ShortRightArrow]En+P2, k2},
{S1+NC[En,Inh]\[RightArrowLeftArrow]NC[S1,En,Inh], kf1, kr1},{NC[S1,En,Inh]\[ShortRightArrow]NC[En,Inh]+P1,residualRate*k1},
{S2+NC[Enx,Inh]\[RightArrowLeftArrow]NC[S2,Enx,Inh], kf2, kr2},{NC[S2,Enx,Inh]\[ShortRightArrow]NC[Enx,Inh]+P2,residualRate*k2},
{En+Inh\[RightArrowLeftArrow]NC[En,Inh],kfi,kri},{NC[S1,En]+Inh\[RightArrowLeftArrow]NC[S1,En,Inh],kfi,kri},
{Enx+Inh\[RightArrowLeftArrow]NC[Enx,Inh],kfi,kri},{NC[S2,Enx]+Inh\[RightArrowLeftArrow]NC[S2,Enx,Inh],kfi,kri}};

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_, Enx_\)]\),PingPong[kf1_,kr1_,k1_,kf2_,kr2_,k2_],NCI[Inh_,kfi1_,kri1_,kfi2_,kri2_,residualRate_]]:={{S1+En\[RightArrowLeftArrow]NC[S1,En], kf1, kr1},{NC[S1,En]\[ShortRightArrow]Enx+P1, k1},
{S2+Enx\[RightArrowLeftArrow]NC[S2,Enx], kf2, kr2},{NC[S2,Enx]\[ShortRightArrow]En+P2, k2},
{S1+NC[En,Inh]\[RightArrowLeftArrow]NC[S1,En,Inh], kf1, kr1},{NC[S1,En,Inh]\[ShortRightArrow]NC[En,Inh]+P1,residualRate*k1},
{S2+NC[Enx,Inh]\[RightArrowLeftArrow]NC[S2,Enx,Inh], kf2, kr2},{NC[S2,Enx,Inh]\[ShortRightArrow]NC[Enx,Inh]+P2,residualRate*k2},
{En+Inh\[RightArrowLeftArrow]NC[En,Inh],kfi1,kri1},{NC[S1,En]+Inh\[RightArrowLeftArrow]NC[S1,En,Inh],kfi1,kri1},
{Enx+Inh\[RightArrowLeftArrow]NC[Enx,Inh],kfi2,kri2},{NC[S2,Enx]+Inh\[RightArrowLeftArrow]NC[S2,Enx,Inh],kfi2,kri2}};

(* PingPong Model with non-competitive inhibition for the 2nd substrate *)
Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_, Enx_\)]\),PingPong[kf1_,kr1_,k1_,kf2_,kr2_,k2_],NCI2[Inh_,kfi_,kri_,residualRate_]]:={{S1+En\[RightArrowLeftArrow]NC[S1,En], kf1, kr1},{NC[S1,En]\[ShortRightArrow]Enx+P1, k1},
{S2+Enx\[RightArrowLeftArrow]NC[S2,Enx], kf2, kr2},{NC[S2,Enx]\[ShortRightArrow]En+P2, k2},
{S1+NC[En,Inh]\[RightArrowLeftArrow]NC[S1,En,Inh], kf1, kr1},{NC[S1,En,Inh]\[ShortRightArrow]NC[En,Inh]+P1,residualRate*k1},
{S2+NC[Enx,Inh]\[RightArrowLeftArrow]NC[S2,Enx,Inh], kf2, kr2},{NC[S2,Enx,Inh]\[ShortRightArrow]NC[Enx,Inh]+P2,residualRate*k2},
{Enx+Inh\[RightArrowLeftArrow]NC[Enx,Inh],kfi,kri},{NC[S2,Enx]+Inh\[RightArrowLeftArrow]NC[S2,Enx,Inh],kfi,kri}};


(* PingPong Model with Competitive Inhibition for the 1st substrate reaction, and Non-Competitive Inhibition for the 2nd substrate reaction *)

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_, Enx_\)]\),PingPong[kf1_,kr1_,k1_,kf2_,kr2_,k2_],CI[Inh1_,kfi1_,kri1_],NCI[Inh2_,kfi2_,kri2_]]:={{S1+En\[RightArrowLeftArrow]NC[S1,En], kf1, kr1},{NC[S1,En]\[ShortRightArrow]Enx+P1, k1},
{En+Inh1\[RightArrowLeftArrow]NC[En,Inh1],kfi1,kri1},
{S2+Enx\[RightArrowLeftArrow]NC[S2,Enx], kf2, kr2},{NC[S2,Enx]\[ShortRightArrow]En+P2, k2},
{Enx+Inh2\[RightArrowLeftArrow]NC[Enx,Inh2],kfi2,kri2},{NC[S2,Enx]+Inh2\[RightArrowLeftArrow]NC[S2,Enx,Inh2],kfi2,kri2},
{S2+NC[Enx,Inh2]\[RightArrowLeftArrow]NC[S2,Enx,Inh2],kf2,kr2}};


(* PingPong Model with 3substrates and 3 products *)

(* pingpong with part orderedBiBi *)

(* random addition, ordered release *)
Enz[

\!\(\*OverscriptBox[\({S1_, S2_, S3_} \[RightArrowLeftArrow] {P1_, P2_, P3_}\), \(En_, Enx_, Eny_\)]\),PingPongTerTerF[kf1_,kr1_,k1_,kf2_,kr2_,k2_,kf3_,kr3_,k3_]]:={{S1+S2+En\[RightArrowLeftArrow]NC[S1,S2,En],kf1,kr1},{NC[S1,S2,En]\[ShortRightArrow]P1+Enx,k1},{Enx\[RightArrowLeftArrow]NC[Eny,P2],kf2,kr2},{NC[Eny,P2]\[ShortRightArrow]Eny+P2,k2},{S3+Eny\[RightArrowLeftArrow]NC[S3,Eny],kf3,kr3},{NC[S3,Eny]\[ShortRightArrow]En+P3,k3}};

(* ordered addition, random release *)
Enz[

\!\(\*OverscriptBox[\({S1_, S2_, S3_} \[RightArrowLeftArrow] {P1_, P2_, P3_}\), \(En_, Enx_, Eny_\)]\),PingPongTerTerR[kf1_,kr1_,k1_,kf2_,kr2_,k2_,kf3_,kr3_,k3_]]:={{S1+En\[RightArrowLeftArrow]NC[S1,En],kf1,kr1},{NC[S1,En]\[ShortRightArrow]Enx+P1,k1},{Enx+S2\[RightArrowLeftArrow]NC[Enx,S2],kf2,kr2},{NC[Enx,S2]\[ShortRightArrow]Eny,k2},{S3+Eny\[RightArrowLeftArrow]NC[S3,Eny],kf3,kr3},{NC[S3,Eny]\[ShortRightArrow]En+P2+P3,k3}};


(* PingPong Model with Three Inhibitors Non-Competitive Inhibition *)

Enz[

\!\(\*OverscriptBox[\({S1_, S2_} \[RightArrowLeftArrow] {P1_, P2_}\), \(En_, Enx_\)]\),PingPong[kf1_,kr1_,k1_,kf2_,kr2_,k2_],NCmI[{Inh1_,kfiInh1_,kriInh1_},{Inh2_,kfiInh2_,kriInh2_},{Inh3_,kfiInh3_,kriInh3_}]]:=
Module[{inhibitorInfo},CatalyticRxn={{S1+Apply[En,{0,0,0}]\[RightArrowLeftArrow]NC2[S1,Apply[En,{0,0,0}]], kf1, kr1},{NC2[S1,Apply[En,{0,0,0}]]\[ShortRightArrow]Apply[Enx,{0,0,0}]+P1,k1},
{S2+Apply[Enx,{0,0,0}]\[RightArrowLeftArrow]NC2[S2,Apply[Enx,{0,0,0}]], kf2, kr2},
{NC2[S2,Apply[Enx,{0,0,0}]]\[ShortRightArrow]Apply[En,{0,0,0}]+P2,k2}};
inhibitorInfo={{Inh1, kfiInh1,kriInh1}, {Inh2, kfiInh2,kriInh2},{Inh3, kfiInh3,kriInh3}};
For[inhibitor=1,inhibitor<=3,inhibitor++,InhibitionRxn[inhibitor]=Flatten[Table[{
{Apply[En,RotateRight[{0,j,k},inhibitor-1]]+inhibitorInfo[[inhibitor,1]]\[RightArrowLeftArrow]Apply[En,RotateRight[{1,j,k},inhibitor-1]],inhibitorInfo[[inhibitor,2]],inhibitorInfo[[inhibitor,3]]},
{NC2[S1,Apply[En,RotateRight[{0,j,k},inhibitor-1]]]+inhibitorInfo[[inhibitor,1]]\[RightArrowLeftArrow]
   NC2[S1,Apply[En,RotateRight[{1,j,k},inhibitor-1]]],inhibitorInfo[[inhibitor,2]],inhibitorInfo[[inhibitor,3]]},
{Apply[Enx,RotateRight[{0,j,k},inhibitor-1]]+inhibitorInfo[[inhibitor,1]]\[RightArrowLeftArrow]
   Apply[Enx,RotateRight[{1,j,k},inhibitor-1]],inhibitorInfo[[inhibitor,2]],inhibitorInfo[[inhibitor,3]]},
{NC2[S2,Apply[Enx,RotateRight[{0,j,k},inhibitor-1]]]+inhibitorInfo[[inhibitor,1]]\[RightArrowLeftArrow]NC2[S2,Apply[Enx,RotateRight[{1,j,k},inhibitor-1]]],inhibitorInfo[[inhibitor,2]],inhibitorInfo[[inhibitor,3]]}
},{j,0,1},{k,0,1}],1]];
Union[CatalyticRxn,Flatten[Map[InhibitionRxn,{1,2,3}],2]]];



Print[Style[" kMech "<>kMech`Private`$KmechVersion<>" is loaded ",FontFamily->"Ubuntu,Arial"]];
EndPackage[ ];
