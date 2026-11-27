import { bindings, defineConfig, triggers } from "cf/config";

export default defineConfig({
	worker: {
		name: "studio2201-contact",
		compatibilityDate: "2026-11-26",
		entrypoint: "worker.js",
		triggers: [
			triggers.fetch({
				pattern: "studio2201.com/api/contact",
				zone: "studio2201.com",
			}),
			triggers.fetch({
				pattern: "www.studio2201.com/api/contact",
				zone: "studio2201.com",
			}),
		],
		env: {
			EMAIL: bindings.sendEmail({}),
		},
	},
});
