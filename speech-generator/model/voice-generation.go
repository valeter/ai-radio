package model

type FileType string

const (
	MP3 FileType = "MP3"
)

type Voice string

// russian voices
const (
	Alena     Voice = "alena"
	Filipp    Voice = "filipp"
	Ermil     Voice = "ermil"
	Jane      Voice = "jane"
	Madi      Voice = "madi_ru"
	Saule     Voice = "saule_ru"
	Omazh     Voice = "omazh"
	Zahar     Voice = "zahar"
	Dasha     Voice = "dasha"
	Julia     Voice = "julia"
	Lera      Voice = "lera"
	Masha     Voice = "masha"
	Marina    Voice = "marina"
	Alexander Voice = "alexander"
	Kirill    Voice = "kirill"
	Anton     Voice = "anton"
)

type Role string

// roles
const (
	Neutral  Role = "neutral"
	Strict   Role = "strict"
	Good     Role = "good"
	Evil     Role = "evil"
	Friendly Role = "friendly"
	Whisper  Role = "whisper"
)

var RoleVoices = map[Role][]Voice{
	Neutral:  {Alena, Ermil, Jane, Omazh, Zahar, Dasha, Julia, Lera, Marina, Alexander, Kirill, Anton},
	Strict:   {Julia, Kirill},
	Good:     {Alena, Ermil, Jane, Zahar, Dasha, Alexander, Kirill, Anton},
	Evil:     {Jane, Omazh},
	Friendly: {Dasha, Lera, Marina},
	Whisper:  {Marina},
}

type VoiceGenerationRequest struct {
	Text           string
	ResultFileType FileType
	Speed          int // 0 to 20, translates to 0.0 to 2.0 in tts request
	TtsVoice       Voice
	TtsRole        Role
	S3Bucket       string
	S3Folder       string
	S3UniqueKey    string
}
