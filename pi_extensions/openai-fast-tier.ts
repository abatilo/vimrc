import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

type ServiceTier = "auto" | "default" | "flex" | "priority";

const SERVICE_TIER: ServiceTier = "priority";
const OPENAI_PROVIDERS = new Set(["openai", "openai-codex"]);
const OPENAI_APIS = new Set(["openai-responses", "openai-codex-responses", "openai-completions"]);

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}

export default function (pi: ExtensionAPI) {
	pi.on("before_provider_request", (event, ctx) => {
		const model = ctx.model;
		if (!model) return;
		if (!OPENAI_PROVIDERS.has(model.provider)) return;
		if (!OPENAI_APIS.has(model.api)) return;
		if (!isRecord(event.payload)) return;

		return {
			...event.payload,
			service_tier: SERVICE_TIER,
		};
	});
}
