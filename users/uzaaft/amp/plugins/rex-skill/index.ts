import type { PluginAPI } from '@ampcode/plugin'

export const description = 'Adds the Rex workspace skill and inherited terminal context, including automatic task-based session naming.'

export default async function (amp: PluginAPI) {
	await amp.registerSkill({ path: 'skills/rex' })

	amp.on('agent.start', async (_event, ctx) => {
		const server = process.env.REX_SERVER
		const session = process.env.REX_SESSION
		const block = process.env.REX_BLOCK

		if (server === undefined || session === undefined || block === undefined) {
			return {}
		}

		const rex = await ctx.$`command -v rex`
		const availability =
			rex.exitCode === 0
				? `The rex CLI is on PATH. As part of handling a substantive request, inspect the current session label and run \`rex session rename "${session}" <label>\` when the label is generic or the topic has materially changed. Use two to four lowercase hyphenated words naming the task, not the tool. Do this unprompted once the work is clear; skip greetings and bare launches. If inspection or rename fails, continue the user's task.`
				: 'The rex CLI is not on this hook process PATH; locate it before attempting Rex operations.'

		return {
			message: {
				content: [
					'This process has inherited a Rex terminal context:',
					`REX_SERVER=${server}`,
					`REX_SESSION=${session}`,
					`REX_BLOCK=${block}`,
					'',
					'REX_SESSION identifies the containing session; REX_BLOCK identifies this terminal, which may differ from the currently focused pane.',
					availability,
				].join('\n'),
			},
		}
	})
}
