#!/usr/bin/env bash
# Valida as fichas de receitas.
# Uso: bash scripts/valida.sh   (corre na raiz do repositório)

shopt -s nullglob
fichas=(selecoes/*.md)

if [ ${#fichas[@]} -eq 0 ]; then
  echo "::error::Não encontrei fichas em selecoes/*.md"
  exit 1
fi

erros=0
for f in "${fichas[@]}"; do
  # ingredientes: linhas não vazias entre "Ingredientes" e "Instruções"
  ingredientes=$(awk '/^Instruções/{p=0} /^Ingredientes/{p=1; next} p && NF{n++} END{print n+0}' "$f")

  if [ "$ingredientes" -lt 3 ]; then
    echo "::error file=$f::$f tem $ingredientes ingredientes (mínimo: 3)"
    erros=$((erros + 1))
  fi

  for campo in "Doses:" "Tempo de preparação:" "Tempo de cozimento:"; do
    if ! grep -qE "^[[:space:]]*$campo[[:space:]]*[^[:space:]]" "$f"; then
      echo "::error file=$f::$f não tem o campo $campo preenchido"
      erros=$((erros + 1))
    fi
  done

  for seccao in "Ingredientes" "Instruções"; do
    if ! grep -qE "^[[:space:]]*$seccao[[:space:]]*$" "$f"; then
      echo "::error file=$f::$f não tem a secção $seccao"
      erros=$((erros + 1))
    fi
  done

  echo "$f: $ingredientes ingredientes"
done

if [ "$erros" -gt 0 ]; then
  echo "Encontrei $erros erro(s)."
  exit 1
fi

echo "Todas as seleções estão válidas."