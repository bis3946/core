import Lake
open Lake DSL

package «nun_core» where
  moreLeanArgs := #["-DautoImplicit=false"]

@[default_target]
lean_lib «NunQuantumProof» where
  roots := #[`nun_quantum_proof]
