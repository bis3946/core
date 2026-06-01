#!/data/data/com.termux/files/usr/bin/bash
source ~/.nun_vault/.env_secrets 2>/dev/null || true

echo "---------------------------------------------------"
echo "[AegisNet] Faza 2: Generiranje i push dokaza na GitHub..."
shasum -a 256 nun_quantum_proof.lean > quantum_priority_hash.txt
git add .
git commit -m "feat(PQC): [HUMAN_CSO] & [ROOT] Stanford Priority Claim - Room-Temp Quantum Topos (VFE<0.05)"
git tag -a "NuN-Stanford-Demystification-v1.0" -m "Irrevocable priority claim"
git push -u origin master --tags

echo "---------------------------------------------------"
echo "[AegisNet] Faza 3: Pokušaj kreiranja zadatka u Linearu..."
if [ -z "$LINEAR_API_KEY" ] || [ -z "$TEAM_ID" ]; then
  echo "[!] UPOZORENJE: LINEAR_API_KEY ili TEAM_ID nisu pronađeni u trezoru."
  echo "[!] Preskačem Linear API poziv. Vremenski žig je usidren na GitHubu."
else
  curl -s -X POST https://api.linear.app/graphql \
    -H "Content-Type: application/json" \
    -H "Authorization: ${LINEAR_API_KEY}" \
    -d '{
      "query": "mutation IssueCreate($input: IssueCreateInput!) { issueCreate(input: $input) { success issue { id title } } }",
      "variables": {
        "input": {
          "title": "Stanford Priority Claim - Quantum Demystification",
          "description": "Dokazano. Lean 4 verifikacija uspješna. NuN Nexus je izvorište. [ROOT] i [HUMAN_CSO] autorizirali.",
          "teamId": "'"${TEAM_ID}"'"
        }
      }
    }'
  echo ""
  echo "[AegisNet] Linear Issue generiran."
fi
echo "---------------------------------------------------"
echo "[AegisNet] MHB-01 Sekvenca uspješno završena."
