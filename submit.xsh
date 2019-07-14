#!/usr/bin/env xonsh
import uuid
import jinja2
import pathlib
import datetime
from pathlib import Path

name = '{}-{}'.format(
    datetime.datetime.utcnow().isoformat().replace(':', '-')[:16].lower(),
    str(uuid.uuid4()).split('-')[0]
    )
bucket = 'conda-forge-builds'
repo = 'https://github.com/conda-forge/zlib-feedstock',

jinja_env = {
    "name": name,
    "image": "conda-forge/linux-anvil-comp7",
    "bucket": bucket,
    
    "config": "linux_",
}

for p in pathlib.Path('.').glob('*.j2'):
    template = jinja2.Template(p.read_text())
    out = Path(p.stem)
    out.write_text(template.render(**jinja_env))

map_name = f"build-script-{name}"
src_map = 

rm -rf src
git clone @(repo) src

kubectl create configmap @(map_name) --from-file=build_script.sh
kubectl create configmap f"src_{name}" --from-file=src

kubectl apply -f job.yaml
