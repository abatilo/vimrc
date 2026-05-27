---
name: speed-bench-al-eval
description: Run an at-evals DFlash SPEED-Bench acceptance-length evaluation end to end from an S3 checkpoint URI, including upfront recipe analysis, conversion, serving, workload monitoring, and final CSV retrieval.
---

# SPEED-Bench Acceptance Length Eval

Use this skill when the user hands off an S3 checkpoint path and asks to run a DFlash SPEED-Bench acceptance-length evaluation, especially for a new model architecture or checkpoint family. The expected finish line is the final `speed_bench_report.csv` printed to stdout with the exact `aws --profile cwstudio s3 cp ... -` command that produced it.

## Required Start

1. Work in `/Users/abatilo/work/at` unless the user names a different checkout.
2. Create and maintain a task list immediately.
3. Read applicable repo instructions and recent git notes before editing or submitting anything.
4. Inspect the existing acceptance-length recipe, starting with `recipes/evals/k26_dflash_acc_len.py`.
5. Inspect the provided S3 checkpoint with `aws --profile cwstudio s3 ls`, including recursive spot checks when needed.
6. Do all upfront analysis before calling `create_goal()`. For an end-to-end eval request using this skill, treat the user handoff as permission to create a concrete goal after the analysis is complete.

## Upfront Analysis

Answer these questions from the checkout and live artifacts before implementing:

- What recipe is the closest existing pattern, and what does it assume about model family, target model, draft model, output path, jobset name, and SPEED-Bench invocation?
- What files exist in the checkpoint prefix, and do they identify the architecture, tensor naming, config shape, tokenizer source, iteration, and version slug?
- Is a serving target model already available, or must the recipe point at a known base/quantized target model S3 path?
- What conversion stage is required before serving, and which artifacts should it upload?
- What final S3 output prefix should contain `speed-bench/speed_bench_report.csv`?
- Which tests or dry-run renders prove the recipe compiles and renders correctly before submission?

Do not hardcode a prior run's version or output prefix unless the input checkpoint is that exact run. Derive names from the provided S3 checkpoint and existing repo conventions.

## Implementation

Keep changes narrowly scoped to the eval recipe and the smallest supporting at-evals code needed for that architecture. Follow existing rendering and jobset patterns instead of inventing new abstractions.

Use `apply_patch` for manual edits. Preserve unrelated user changes in the worktree. If generated or previous partial S3 artifacts are stale, inspect and explain before deleting anything; only clean artifacts that clearly belong to the current failed attempt.

Load `references/at-evals-dflash-speed-bench.md` when you need command details, monitoring checks, or the MiniMax M2.7 example from the session that created this skill.

## Verification

Before submitting the workload, run focused checks such as:

```bash
uv run python -m py_compile packages/at-evals/src/at/evals/dflash.py packages/at-evals/src/at/evals/steps.py packages/at-evals/src/at/evals/serving.py packages/at-evals/src/at/evals/_platform/rendering.py recipes/evals/<recipe>.py
uv run pytest packages/at-evals/tests/test_rendering.py tests/test_vllm_dflash_convert_job.py -q
```

Also dry-run or render the recipe with the actual checkpoint URI when the recipe supports it. Fix local validation failures before submitting.

## Submit And Watch

Submit the recipe only after validation passes. Watch the workload through conversion, serving startup, SPEED-Bench execution, and result upload. Check Kubernetes JobSet status, init logs, serving logs, and benchmark logs as needed; do not stop at "submitted" when the user asked for the final CSV.

If the workload fails, inspect the newest logs and artifacts first, identify the real failing stage, patch narrowly, rerun validation, and resubmit.

## Finish

Fetch and print the acceptance-length CSV from the final output prefix:

```bash
aws --profile cwstudio s3 cp s3://cwstudio/<output-prefix>/speed-bench/speed_bench_report.csv -
```

Report the exact command and stdout. If a goal was created, mark it complete only after the CSV has been fetched and the final results are available.
