#!/usr/bin/env bash

set -euo pipefail

# ---------- Colors ----------
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
RESET="\e[0m"

# ---------- Helpers ----------
error() {
  printf "%b\n" "${RED}❌ $1${RESET}"
  exit 1
}

info() {
  printf "%b\n" "${BLUE}ℹ️  $1${RESET}"
}

success() {
  printf "%b\n" "${GREEN}✅ $1${RESET}"
}

# ---------- Preconditions ----------
git rev-parse --is-inside-work-tree &>/dev/null || error "Not a git repository"

CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null) \
  || error "Detached HEAD state. Cannot determine branch."

info "Current branch: ${CURRENT_BRANCH}"

# ---------- Input ----------
while true; do
  read -r -p "Commit message: " MESSAGE

  if [[ -z "${MESSAGE// }" ]]; then
    printf "%b\n" "${YELLOW}⚠️  Commit message cannot be empty${RESET}"
  else
    break
  fi
done

# ---------- Git Operations ----------
info "Staging changes..."
git add .

if git diff --cached --quiet; then
  error "No changes staged for commit"
fi

info "Creating commit..."
git commit -m "$MESSAGE"

info "Pushing to origin/${CURRENT_BRANCH}..."
git push origin "$CURRENT_BRANCH"

success "Commit and push completed successfully"

# ---------- Optional Exit Countdown ----------
for i in 3 2 1; do
  printf "%b\n" "${BLUE}Exiting in $i...${RESET}"
  sleep 1
done
