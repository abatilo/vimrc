# at-evals DFlash SPEED-Bench Acceptance Length Workflow

This reference captures the operational workflow for running acceptance-length evals from an S3 DFlash checkpoint in `/Users/abatilo/work/at`. It is evidence and process guidance, not a set of defaults to blindly reuse.

## Inputs

Required user input:

- The checkpoint S3 URI, usually under `s3://cwstudio/spec/checkpoints/.../iter_<iteration>/`.

Derived during analysis:

- Recipe name under `recipes/evals/`.
- DFlash checkpoint source path.
- Target model path used by vLLM serving.
- Output root and output version slug.
- Served model name.
- JobSet name.
- Final report URI ending in `speed-bench/speed_bench_report.csv`.

## Read First

Start with the existing K26 recipe:

```bash
sed -n '1,260p' recipes/evals/k26_dflash_acc_len.py
```

Then inspect the local implementation touched by DFlash and SPEED-Bench recipes:

```bash
rg -n "DFlash|dflash|speed_bench|speed-bench|acceptance|JobSet|vllm" recipes packages tests
sed -n '1,260p' packages/at-evals/src/at/evals/dflash.py
sed -n '1,260p' packages/at-evals/src/at/evals/steps.py
sed -n '1,260p' packages/at-evals/src/at/evals/serving.py
sed -n '1,220p' packages/at-evals/src/at/evals/_platform/rendering.py
sed -n '1,260p' tests/test_vllm_dflash_convert_job.py
```

Read recent history with notes before changing recipe behavior:

```bash
git log --show-notes --oneline -20
git log --show-notes --oneline -- recipes/evals/k26_dflash_acc_len.py packages/at-evals/src/at/evals/dflash.py packages/at-evals/src/at/evals/serving.py packages/at-evals/src/at/evals/steps.py
```

## S3 Artifact Inspection

Inspect the input path exactly as provided:

```bash
aws --profile cwstudio s3 ls <checkpoint-s3-uri>
aws --profile cwstudio s3 ls --recursive <checkpoint-s3-uri> | head -100
```

Look for:

- Model config files, tokenizer files, params, safetensors, or manifest files.
- Iteration number and version slug.
- Architecture-specific tensor names and config values.
- Whether the checkpoint is already converted, or needs the DFlash conversion pipeline.

If local AWS credentials cannot read a path but the workload is expected to use in-cluster credentials, verify that assumption with live cluster evidence before changing the recipe around a local `AccessDenied`.

## Recipe Construction

Prefer copying the closest recipe and changing only the values and support hooks required for the new checkpoint family. For a new architecture, expect to verify or add support for:

- Model architecture name and vLLM target model path.
- Draft checkpoint source and conversion output destination.
- Draft model config or parser differences.
- Tokenizer source.
- Output S3 prefix and displayed model name.
- Resource requirements and GPU topology.
- Any architecture-specific conversion arguments.

Avoid embedding one checkpoint's version into generic support code. The recipe may have a default for a specific run, but shared helpers should accept explicit inputs or derive values from the recipe.

## Local Validation

Compile the edited files and run focused tests:

```bash
uv run python -m py_compile packages/at-evals/src/at/evals/dflash.py packages/at-evals/src/at/evals/steps.py packages/at-evals/src/at/evals/serving.py packages/at-evals/src/at/evals/_platform/rendering.py recipes/evals/<recipe>.py
uv run pytest packages/at-evals/tests/test_rendering.py tests/test_vllm_dflash_convert_job.py -q
```

If the recipe supports a checkpoint override, render with the actual input:

```bash
DFLASH_CHECKPOINT_S3=<checkpoint-s3-uri> uv run python recipes/evals/<recipe>.py --dry-run
```

Use the repo's actual submit/dry-run interface if it differs; inspect the recipe before assuming flags.

## Submission

Submit after validation:

```bash
DFLASH_CHECKPOINT_S3=<checkpoint-s3-uri> uv run python recipes/evals/<recipe>.py
```

Capture the rendered JobSet name, namespace, cluster context, and final output prefix. The K26/MiniMax path used `infr-dev-us-e-04b`; do not assume that cluster if the recipe changed.

Useful read-only monitoring commands:

```bash
kubectl config current-context
kubectl get jobsets -A | rg '<jobset-fragment>'
kubectl get pods -n <namespace> | rg '<jobset-fragment>'
kubectl describe jobset -n <namespace> <jobset-name>
kubectl logs -n <namespace> <pod-name> -c <container-name> --tail=200
```

Monitor these stages separately:

- Conversion/init container starts and uploads converted draft artifacts.
- vLLM server starts, loads target and draft models, and opens the serving port.
- SPEED-Bench reaches the served model and completes all tasks.
- Results upload to the expected S3 prefix.

## Failure Handling

When conversion fails:

- Inspect the conversion pod logs and newest S3 artifacts.
- Check for architecture parser mismatches, bad tensor names, missing tokenizer/config, wrong source path, or wrong output path.
- Patch the recipe/support code narrowly, rerun local validation, and resubmit.

When serving fails:

- Inspect vLLM logs for model loader, quantization, DFlash config, parser, port, and OOM errors.
- Verify the converted draft artifacts exist in the path the serving job uses.
- Confirm the target model path is the intended target, not a draft checkpoint.

When SPEED-Bench fails:

- Inspect benchmark logs for request failures, model name mismatch, timeout, or missing route.
- Confirm the served model name in the benchmark command matches the serving container.
- Check whether partial reports were uploaded before assuming the whole run failed.

Do not delete shared or older S3 prefixes while debugging. Only remove artifacts that are unambiguously from the current failed attempt and only when rerun correctness requires it.

## MiniMax M2.7 Evidence From The Creating Session

This example is useful because it exercised a new architecture and included the conversion pipeline. Do not reuse these exact values unless the user gives this exact checkpoint family.

Input checkpoint:

```text
s3://cwstudio/spec/checkpoints/dflash-minimax-m2p7-v001-pb8-hd128-g4-s1337/iter_0010001/
```

Target model:

```text
s3://cwstudio/quantize/minimax-m27-nvfp4-nvidia/
```

Output root:

```text
s3://cwstudio/spec/checkpoints/dflash-minimax-m2p7-serving/
```

JobSet:

```text
al-v001-pb8-hd128-g4-s1337-i0010001
```

Validation that passed before submission:

```text
uv run python -m py_compile packages/at-evals/src/at/evals/dflash.py packages/at-evals/src/at/evals/steps.py packages/at-evals/src/at/evals/serving.py packages/at-evals/src/at/evals/_platform/rendering.py recipes/evals/minimax_m2p7_dflash_acc_len.py
uv run pytest packages/at-evals/tests/test_rendering.py tests/test_vllm_dflash_convert_job.py -q
47 passed in 0.48s
```

Final acceptance-length command:

```bash
aws --profile cwstudio s3 cp s3://cwstudio/spec/checkpoints/dflash-minimax-m2p7-serving/v001-pb8-hd128-g4-s1337-iter-0010001/speed-bench/speed_bench_report.csv -
```

Final stdout:

```csv
Model,coding,humanities,math,multilingual,qa,rag,reasoning,roleplay,stem,summarization,writing,Overall
minimax-m2p7-v001-pb8-hd128-g4-s1337-dflash,2.73,2.49,2.58,2.78,2.35,2.57,2.50,2.35,2.49,2.47,2.39,2.52
```

The corresponding acceptance-rate report existed too, but the requested deliverable was acceptance length.
