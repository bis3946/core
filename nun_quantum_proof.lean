/-
  NuN Core — Formal Verification of VFE Attenuation & State-Space Projection
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

/-- Non-Commutative Verification Projection Operator P_v: zeroes out speculative channel s2 -/
def projectVerified (st : EpistemicState) : EpistemicState :=
  { s1 := st.s1, s2 := 0 }

/-- Variational Free Energy (VFE) surplus above baseline F_0 at room temperature -/
def vfeSurplus (p : ThermalParams) (st : EpistemicState) : Int :=
  p.kB * p.tempK * (st.s2 * st.s2)

/-- Theorem 1: Projection Operator P_v is strictly idempotent: P_v(P_v(S)) = P_v(S) -/
theorem projection_idempotent (st : EpistemicState) :
    projectVerified (projectVerified st) = projectVerified st := by
  rfl

/-- Theorem 2: Applying P_v strictly collapses VFE surplus to exact zero at room temperature -/
theorem vfe_surplus_zero_after_projection (p : ThermalParams) (st : EpistemicState) :
    vfeSurplus p (projectVerified st) = 0 := by
  dsimp [vfeSurplus, projectVerified]
  simp [Int.mul_zero]

/-- Theorem 3: Non-zero speculative entropy strictly generates positive VFE dissipation demand -/
theorem vfe_pos_of_nonzero_entropy (p : ThermalParams) (st : EpistemicState)
    (h_s2 : 0 < st.s2) : 0 < vfeSurplus p st := by
  dsimp [vfeSurplus]
  have h_kt : 0 < p.kB * p.tempK := Int.mul_pos p.h_kB_pos p.h_temp_pos
  have h_sq : 0 < st.s2 * st.s2 := Int.mul_pos h_s2 h_s2
  exact Int.mul_pos h_kt h_sq
