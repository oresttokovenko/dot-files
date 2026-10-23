/**
 * Question Tool - one or more questions, each multiple choice or fill-in-the-blank.
 *
 * A question with `options` is a picker (arrows / 1-9 / Enter, plus an inline
 * "Type something." editor). A question without `options` is fill-in-the-blank:
 * every run of 2+ underscores in the question text becomes one text field, so
 * `The capital of ___ is ___` asks for two blanks. Questions are shown one at a
 * time; Esc steps back a question, Ctrl+C cancels the whole set.
 *
 * Blanks are graded by the model by default. Pass `expected` (one value per
 * blank) to have the extension check each answer exactly (trimmed, case- and
 * whitespace-insensitive) and report correct/incorrect in the result.
 *
 * Local deltas vs upstream example (pi 1.3.0): number-key shortcuts 1-9,
 * resize-safe render cache, Ctrl+C cancels the picker, batched questions,
 * multi-blank text fields.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
	Editor,
	type EditorTheme,
	Input,
	Key,
	matchesKey,
	Text,
	visibleWidth,
	wrapTextWithAnsi,
} from "@earendil-works/pi-tui";
import { Type } from "typebox";

interface OptionWithDesc {
	label: string;
	description?: string;
}

type DisplayOption = OptionWithDesc & { isOther?: boolean };

interface AnswerRecord {
	question: string;
	kind: "choice" | "custom" | "blanks";
	/** Choice label, typed answer, or the blank values in order. */
	value: string | string[];
	/** 1-based option number for choice answers. */
	index?: number;
	/** Present when the question declared expected blank answers. */
	expected?: string[];
	/** Exact-match verdict for `expected`; absent when the model grades. */
	correct?: boolean;
}

interface QuestionDetails {
	/** null when the user cancelled. */
	answers: AnswerRecord[] | null;
}

const BLANK_PATTERN = /_{2,}/g;

/** Number of blanks in a question; a question without ___ gets one field. */
function blankCount(question: string): number {
	return Math.max(1, question.match(BLANK_PATTERN)?.length ?? 0);
}

function formatAnswer(record: AnswerRecord): string {
	if (Array.isArray(record.value)) {
		const values = JSON.stringify(record.value);
		if (record.correct === undefined) return values;
		return record.correct ? `${values} ✓` : `${values} ✗ expected ${JSON.stringify(record.expected)}`;
	}
	if (record.kind === "custom") return `${record.value} (typed)`;
	if (record.index) return `${record.index}. ${record.value}`;
	return record.value;
}

/** Exact-answer comparison: trimmed, case-insensitive, whitespace-collapsed. */
function normalizeAnswer(value: string): string {
	return value.trim().toLowerCase().replace(/\s+/g, " ");
}

const OptionSchema = Type.Object({
	label: Type.String({ description: "Display label for the option" }),
	description: Type.Optional(Type.String({ description: "Optional description shown below label" })),
});

const QuestionItemSchema = Type.Object({
	question: Type.String({
		description:
			"Question text. For fill-in-the-blank, write a run of two or more underscores (___) for each field; each run becomes one text field. Without underscores one field is shown.",
	}),
	options: Type.Optional(
		Type.Array(OptionSchema, {
			description: "Multiple-choice options. When present the user picks one and underscores are ignored.",
		}),
	),
	placeholder: Type.Optional(Type.String({ description: "Hint shown inside empty fill-in-the-blank fields" })),
	expected: Type.Optional(
		Type.Array(Type.String(), {
			description:
				"Exact answer for each blank, in order (trimmed, case- and whitespace-insensitive). Omit to accept any answer and let the model grade it. Not allowed on multiple-choice questions.",
		}),
	),
});

const QuestionParams = Type.Object({
	questions: Type.Array(QuestionItemSchema, {
		minItems: 1,
		description: "Questions to ask, shown one at a time. Use several to collect a whole form in one call.",
	}),
});

export default function question(pi: ExtensionAPI) {
	pi.registerTool({
		name: "question",
		label: "Question",
		description:
			"Ask the user one or more questions and wait for answers. Each question is multiple choice (pass options) or fill-in-the-blank (omit options; every ___ run in the question text is a text field). Blanks accept any answer unless `expected` is given, which makes the extension check them exactly. Questions are shown one at a time: Esc steps back, Ctrl+C cancels.",
		parameters: QuestionParams,
		executionMode: "sequential",

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			const specs = params.questions;
			const fail = (text: string) => ({
				content: [{ type: "text" as const, text }],
				details: { answers: null } as QuestionDetails,
			});

			if (ctx.mode !== "tui") {
				return fail("Error: UI not available (running in non-interactive mode)");
			}
			if (specs.length === 0) {
				return fail("Error: No questions provided");
			}
			for (let i = 0; i < specs.length; i++) {
				const spec = specs[i];
				if (!spec.expected) continue;
				if (spec.options?.length) {
					return fail(`Error: question ${i + 1} has options, so it cannot have expected answers`);
				}
				const blanks = blankCount(spec.question);
				if (spec.expected.length !== blanks) {
					return fail(
						`Error: question ${i + 1} has ${blanks} blank(s) but ${spec.expected.length} expected answer(s)`,
					);
				}
			}

			const result = await ctx.ui.custom<AnswerRecord[] | null>((tui, theme, _kb, done) => {
				let questionIndex = 0;
				const answers: AnswerRecord[] = [];
				let cachedLines: string[] | undefined;
				let cachedWidth = -1;

				const editorTheme: EditorTheme = {
					borderColor: (s) => theme.fg("accent", s),
					selectList: {
						selectedPrefix: (t) => theme.fg("accent", t),
						selectedText: (t) => theme.fg("accent", t),
						description: (t) => theme.fg("muted", t),
						scrollInfo: (t) => theme.fg("dim", t),
						noMatch: (t) => theme.fg("warning", t),
					},
				};
				const editor = new Editor(tui, editorTheme);

				interface QuestionState {
					choiceIndex: number;
					editMode: boolean;
					/** Answer typed into "Type something.", null while unused. */
					custom: string | null;
					fieldIndex: number;
					inputs: Input[];
				}

				const states: QuestionState[] = specs.map((spec) => ({
					choiceIndex: 0,
					editMode: false,
					custom: null,
					fieldIndex: 0,
					inputs: spec.options?.length
						? []
						: Array.from(
								{ length: blankCount(spec.question) },
								() =>
									new Input({
										prompt: "",
										placeholder: spec.placeholder ?? "",
										placeholderStyle: (t) => theme.fg("dim", t),
									}),
							),
				}));

				const currentSpec = () => specs[questionIndex];
				const currentState = () => states[questionIndex];
				const isChoice = () => (currentSpec().options?.length ?? 0) > 0;
				const allOptions = (): DisplayOption[] => [
					...(currentSpec().options ?? []),
					{ label: "Type something.", isOther: true },
				];

				function refresh() {
					cachedLines = undefined;
					tui.requestRender();
				}

				function applyFocus() {
					const state = currentState();
					const editing = isChoice() && state.editMode;
					editor.focused = editing;
					for (let i = 0; i < state.inputs.length; i++) {
						state.inputs[i].focused = !editing && i === state.fieldIndex;
					}
				}

				function submitCurrent() {
					const spec = currentSpec();
					const state = currentState();
					if (isChoice()) {
						if (state.custom !== null) {
							answers[questionIndex] = { question: spec.question, kind: "custom", value: state.custom };
						} else {
							const option = spec.options?.[state.choiceIndex];
							if (!option) return;
							answers[questionIndex] = {
								question: spec.question,
								kind: "choice",
								value: option.label,
								index: state.choiceIndex + 1,
							};
						}
					} else {
						const value = state.inputs.map((input) => input.getValue().trim());
						const expected = spec.expected;
						answers[questionIndex] = {
							question: spec.question,
							kind: "blanks",
							value,
							...(expected
								? {
										expected,
										correct: value.every((answer, i) => normalizeAnswer(answer) === normalizeAnswer(expected[i] ?? "")),
									}
								: {}),
						};
					}

					if (questionIndex === specs.length - 1) {
						done(answers);
						return;
					}
					questionIndex += 1;
					applyFocus();
					refresh();
				}

				function choose(index: number) {
					const state = currentState();
					const option = allOptions()[index];
					if (!option) return;
					state.choiceIndex = index;
					if (option.isOther) {
						state.editMode = true;
						editor.setText(state.custom ?? "");
						applyFocus();
						refresh();
						return;
					}
					state.custom = null;
					state.editMode = false;
					submitCurrent();
				}

				function stepBack() {
					if (questionIndex === 0) {
						done(null);
						return;
					}
					questionIndex -= 1;
					applyFocus();
					refresh();
				}

				editor.onSubmit = (value) => {
					const trimmed = value.trim();
					const state = currentState();
					if (!trimmed) {
						state.editMode = false;
						editor.setText("");
						applyFocus();
						refresh();
						return;
					}
					state.custom = trimmed;
					state.editMode = false;
					submitCurrent();
				};

				function handleInput(data: string) {
					if (matchesKey(data, "ctrl+c")) {
						done(null);
						return;
					}

					const state = currentState();

					if (state.editMode) {
						if (matchesKey(data, Key.escape)) {
							state.editMode = false;
							editor.setText("");
							applyFocus();
							refresh();
							return;
						}
						editor.handleInput(data);
						refresh();
						return;
					}

					if (matchesKey(data, Key.escape)) {
						stepBack();
						return;
					}

					if (isChoice()) {
						const options = allOptions();
						if (matchesKey(data, Key.up)) {
							state.choiceIndex = Math.max(0, state.choiceIndex - 1);
							refresh();
							return;
						}
						if (matchesKey(data, Key.down)) {
							state.choiceIndex = Math.min(options.length - 1, state.choiceIndex + 1);
							refresh();
							return;
						}
						if (matchesKey(data, Key.enter)) {
							choose(state.choiceIndex);
							return;
						}
						for (let n = 1; n <= Math.min(9, options.length); n++) {
							if (matchesKey(data, String(n))) {
								choose(n - 1);
								return;
							}
						}
						return;
					}

					const lastField = state.inputs.length - 1;
					if (matchesKey(data, "shift+tab") || matchesKey(data, Key.up)) {
						state.fieldIndex = Math.max(0, state.fieldIndex - 1);
						applyFocus();
						refresh();
						return;
					}
					if (matchesKey(data, Key.down)) {
						state.fieldIndex = Math.min(lastField, state.fieldIndex + 1);
						applyFocus();
						refresh();
						return;
					}
					if (matchesKey(data, Key.tab) || matchesKey(data, Key.enter)) {
						if (state.fieldIndex === lastField) {
							submitCurrent();
						} else {
							state.fieldIndex += 1;
							applyFocus();
							refresh();
						}
						return;
					}

					state.inputs[state.fieldIndex]?.handleInput(data);
					refresh();
				}

				function render(width: number): string[] {
					if (cachedLines && cachedWidth === width) return cachedLines;

					const lines: string[] = [];
					const renderWidth = Math.max(1, width);

					function addWrapped(text: string) {
						lines.push(...wrapTextWithAnsi(text, renderWidth));
					}

					function addWrappedWithPrefix(prefix: string, text: string) {
						const prefixWidth = visibleWidth(prefix);
						if (prefixWidth >= renderWidth) {
							addWrapped(prefix + text);
							return;
						}
						const wrapped = wrapTextWithAnsi(text, renderWidth - prefixWidth);
						const continuationPrefix = " ".repeat(prefixWidth);
						for (let i = 0; i < wrapped.length; i++) {
							lines.push(`${i === 0 ? prefix : continuationPrefix}${wrapped[i]}`);
						}
					}

					const spec = currentSpec();
					const state = currentState();
					const choice = isChoice();

					lines.push(theme.fg("accent", "─".repeat(renderWidth)));
					if (specs.length > 1) {
						addWrappedWithPrefix(" ", theme.fg("muted", `Question ${questionIndex + 1}/${specs.length}`));
					}
					addWrappedWithPrefix(" ", theme.fg("text", spec.question));
					lines.push("");

					if (choice) {
						const options = allOptions();
						for (let i = 0; i < options.length; i++) {
							const option = options[i];
							const selected = i === state.choiceIndex;
							const isOther = option.isOther === true;
							const prefix = selected ? theme.fg("accent", "> ") : "  ";
							const label = `${i + 1}. ${option.label}${isOther && state.editMode ? " ✎" : ""}`;
							const color = selected || (isOther && state.editMode) ? "accent" : "text";

							addWrappedWithPrefix(prefix, theme.fg(color, label));
							if (option.description) {
								addWrappedWithPrefix("     ", theme.fg("muted", option.description));
							}
						}
					} else {
						for (let i = 0; i < state.inputs.length; i++) {
							const focused = i === state.fieldIndex;
							const prefix = focused ? theme.fg("accent", `> ${i + 1}. `) : `  ${i + 1}. `;
							const inputWidth = Math.max(1, renderWidth - visibleWidth(prefix));
							lines.push(prefix + state.inputs[i].render(inputWidth)[0]);
						}
					}

					if (state.editMode) {
						lines.push("");
						addWrappedWithPrefix(" ", theme.fg("muted", "Your answer:"));
						for (const line of editor.render(Math.max(1, renderWidth - 2))) {
							lines.push(` ${line}`);
						}
					}

					lines.push("");
					const back = questionIndex > 0 ? "Esc to go back" : "Esc to cancel";
					if (state.editMode) {
						addWrappedWithPrefix(" ", theme.fg("dim", "Enter to submit • Esc to go back"));
					} else if (choice) {
						addWrappedWithPrefix(" ", theme.fg("dim", `1-9 or ↑↓ • Enter to select • ${back}`));
					} else {
						const move = state.inputs.length > 1 ? "Tab/↑↓ to move • " : "";
						const submit = state.fieldIndex === state.inputs.length - 1 ? "Enter to submit" : "Enter for next blank";
						addWrappedWithPrefix(" ", theme.fg("dim", `${move}${submit} • ${back}`));
					}
					lines.push(theme.fg("accent", "─".repeat(renderWidth)));

					cachedLines = lines;
					cachedWidth = width;
					return lines;
				}

				applyFocus();

				return {
					render,
					invalidate: () => {
						cachedLines = undefined;
					},
					handleInput,
				};
			});

			if (!result) {
				return fail("User cancelled the questions");
			}

			return {
				content: [
					{
						type: "text" as const,
						text: result.map((record, i) => `${i + 1}. ${record.question} → ${formatAnswer(record)}`).join("\n"),
					},
				],
				details: { answers: result } as QuestionDetails,
			};
		},

		renderCall(args, theme, _context) {
			const items = Array.isArray(args.questions) ? args.questions : [];
			const title = items.length === 1 ? items[0].question : `${items.length} questions`;
			let text = theme.fg("toolTitle", theme.bold("question ")) + theme.fg("muted", title);
			for (let i = 0; i < items.length; i++) {
				const item = items[i];
				const options = Array.isArray(item.options) ? item.options : [];
				const detail = options.length
					? `${options.length} options: ${options.map((option) => option.label).join(", ")}`
					: `${blankCount(item.question)} blank${blankCount(item.question) === 1 ? "" : "s"}${
							item.expected ? " (exact)" : ""
						}`;
				const prefix = items.length > 1 ? `${i + 1}. ` : "";
				text += `\n${theme.fg("dim", `  ${prefix}${detail}`)}`;
			}
			return new Text(text, 0, 0);
		},

		renderResult(result, _options, theme, _context) {
			const details = result.details as QuestionDetails | undefined;
			if (!details) {
				const text = result.content[0];
				return new Text(text?.type === "text" ? text.text : "", 0, 0);
			}
			if (!details.answers) {
				return new Text(theme.fg("warning", "Cancelled"), 0, 0);
			}

			const lines = details.answers.map((record, i) => {
				const prefix = details.answers!.length > 1 ? `${i + 1}. ` : "";
				if (Array.isArray(record.value)) {
					const values = JSON.stringify(record.value);
					if (record.correct === false) {
						const suffix =
							record.expected === undefined ? "" : theme.fg("muted", ` — expected ${JSON.stringify(record.expected)}`);
						return theme.fg("warning", "✗ ") + theme.fg("accent", prefix + values) + suffix;
					}
					return theme.fg("success", "✓ ") + theme.fg("accent", prefix + values);
				}
				const shown =
					record.kind === "choice" && record.index
						? `${record.index}. ${record.value}`
						: record.kind === "custom"
							? `(wrote) ${record.value}`
							: JSON.stringify(record.value);
				return theme.fg("success", "✓ ") + theme.fg("accent", prefix + shown);
			});
			return new Text(lines.join("\n"), 0, 0);
		},
	});
}
