/-
  NuN Core — Formal Verification of VFE Attenuation, State-Space Projection & Thin Line Attractor
  Compiler: Lean 4.12.0
  Falsifiable Test Criterion: `lake build` must exit with code 0.
-/

structure ThermalParams where
  kB : Int          -- Scaled Boltzmann constant (> 0)
  tempK : Int       -- Room temperature 295 K (> 0)
  h_kB_pos : 0 < kB
  h_temp_pos : 0 < tempK

structure EpistemicState where
  s1 : Int          -- Channel 0: Verified Coherence
  s2 : Int          -- Channel 1: Speculative Entropy

def projectVerified (st : EpistemicState) : EpistemicState :=
  { s1 := st.s1, s2 := 0 }

def vfeSurplus (p : ThermalParams) (st : EpistemicState) : Int :=
  p.kB * p.tempK * (st.s2 * st.s2)

theorem projection_idempotent (st : EpistemicState) :
    projectVerified (projectVerified st) = projectVerified st := by
  rfl

theorem vfe_surplus_zero_after_projection (p : ThermalParams) (st : EpistemicState) :
    vfeSurplus p (projectVerified st) = 0 := by
  dsimp [vfeSurplus, projectVerified]
  simp [Int.mul_zero]

theorem vfe_pos_of_nonzero_entropy (p : ThermalParams) (st : EpistemicState)
    (h_s2 : 0 < st.s2) : 0 < vfeSurplus p st := by
  dsimp [vfeSurplus]
  have h_kt : 0 < p.kB * p.tempK := Int.mul_pos p.h_kB_pos p.h_temp_pos
  have h_sq : 0 < st.s2 * st.s2 := Int.mul_pos h_s2 h_s2
  exact Int.mul_pos h_kt h_sq

def tleEnergy (X : Int) : Int := X
def tleVoid (X : Int) : Int := 2 - X

def tleFlow (X : Int) (lam : Int) : Int :=
  -lam * (X - 1)

def tleFlowDerivative (lam : Int) : Int :=
  -lam

theorem tle_complementary_conservation (X : Int) :
    tleEnergy X + tleVoid X = 2 := by
  dsimp [tleEnergy, tleVoid]
  omega

theorem tle_equilibrium_at_thin_line (lam : Int) :
    tleFlow 1 lam = 0 := by
  dsimp [tleFlow]
  simp

theorem tle_stability_jacobian_neg (lam : Int) (h_lam : 0 < lam) :
    tleFlowDerivative lam < 0 := by
  dsimp [tleFlowDerivative]
  omega

theorem tle_restoring_force_above_tl (X : Int) (lam : Int)
    (h_lam : 0 < lam) (h_above : 1 < X) : tleFlow X lam < 0 := by
  dsimp [tleFlow]
  have h_diff : 0 < X - 1 := by omega
  have h_prod : 0 < lam * (X - 1) := Int.mul_pos h_lam h_diff
  omega
