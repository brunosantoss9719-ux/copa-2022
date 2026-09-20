extends Node

const TIMELINE_SOLUTION := [
	"ev_pf_2024",
	"ev_stf_judgment_2025",
	"ev_anpp_2026"
]

const RECONSTRUCTION_TITLES := [
	"A investigação comunica uma hipótese",
	"O julgamento altera o que pode ser afirmado",
	"Decisões posteriores preservam situações individuais"
]

const STATUS_SOLUTION := {
	"ev_pf_2024": "ALEGAÇÃO_OFICIAL",
	"ev_stf_judgment_2025": "DECISÃO_JUDICIAL",
	"ev_fiction_draft": "FICÇÃO_DRAMÁTICA"
}

const TIMELINE_HINTS := [
	"Pergunta útil: qual peça descreve investigação, qual registra julgamento e qual só existe depois dele?",
	"Compare a comunicação da PF, o resultado da AP 2696 e a decisão posterior sobre acordos.",
	"A comunicação investigativa vem antes do julgamento; a decisão sobre os acordos é posterior ao julgamento."
]

const STATUS_HINTS := [
	"Pergunta útil: quem está fazendo a afirmação em cada cartão?",
	"Compare a origem institucional dos dois documentos reais com o rascunho interno da investigadora.",
	"Comunicação de investigação continua sendo alegação oficial; decisão do tribunal é decisão judicial; o rascunho da personagem é ficção dramática."
]

func timeline_ready() -> bool:
	if GameState.discovered_evidence.size() < 5:
		return false
	for evidence_id in TIMELINE_SOLUTION:
		if not GameState.has_evidence(evidence_id):
			return false
	return true

func validate_timeline(answer: Array) -> bool:
	if answer.size() != TIMELINE_SOLUTION.size():
		return false
	for i in range(TIMELINE_SOLUTION.size()):
		if str(answer[i]) != TIMELINE_SOLUTION[i]:
			return false
	return true

func status_ready() -> bool:
	if not GameState.reconstruction_complete:
		return false
	for evidence_id in STATUS_SOLUTION.keys():
		if not GameState.has_evidence(evidence_id):
			return false
	return true

func validate_status(answer: Dictionary) -> bool:
	for evidence_id in STATUS_SOLUTION.keys():
		if str(answer.get(evidence_id, "")) != str(STATUS_SOLUTION[evidence_id]):
			return false
	return true

func get_hint(puzzle_id: String, level: int) -> String:
	var hints: Array
	if puzzle_id == "timeline":
		hints = TIMELINE_HINTS
	else:
		hints = STATUS_HINTS
	if hints.is_empty():
		return ""
	return str(hints[clampi(level - 1, 0, hints.size() - 1)])
