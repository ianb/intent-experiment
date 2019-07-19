#!/usr/bin/env bash

set -eu
set -x

here="$(dirname ${BASH_SOURCE[0]})"
venv=./.venv
timestamp="$venv/installed.timestamp"
intent_in=./intents.yaml
intent_out=./.intents.json
cd $here

if [[ ! -d $venv ]] ; then
  python3 -m venv $venv
  $venv/bin/pip install --upgrade pip
  mkdir -p $venv/build
fi

if [[ requirements.txt -nt $timestamp ]] ; then
  ./.venv/bin/pip install -r requirements.txt
  $venv/bin/python -m snips_nlu download en
  for entity in snips/musicAlbum snips/musicTrack snips/musicArtist snips/city snips/region snips/country ; do
    $venv/bin/python -m snips_nlu download-entity $entity en
  done
  touch $timestamp
fi

if [[ $intent_in -nt $intent_out ]] ; then
  $venv/bin/snips-nlu generate-dataset en $intent_in > $intent_out
  rm -rf training/
  $venv/bin/snips-nlu train $intent_out training/
fi

# exec python parse.py "$@"
$venv/bin/snips-nlu parse training/
