#!/usr/bin/env xonsh
import uuid
import jinja2
import pathlib
import datetime
from pathlib import Path

from xonsh.lib.os import indir

name = '{}-{}'.format(
    datetime.datetime.utcnow().isoformat().replace(':', '-')[:16].lower(),
    str(uuid.uuid4()).split('-')[0]
    )
bucket = 'conda-forge-builds'
repo = 'https://github.com/conda-forge/zlib-feedstock',

jinja_env = {
    "name": name,
    "image": "condaforge/linux-anvil-comp7",
    "bucket": bucket,
    "config": "linux_",
}

for p in pathlib.Path('.').glob('*.j2'):
    template = jinja2.Template(p.read_text())
    out = Path(p.stem)
    out.write_text(template.render(**jinja_env))

map_name = f"build-script-{name}"

rm -rf src
git clone @(repo) src
with indir('src'):
    git archive HEAD -o ../src.tar
ls .

kubectl create configmap @(map_name) --from-file=build_script.sh
kubectl create configmap f"src-{name}" --from-file=src.tar

kubectl apply -f job.yaml
