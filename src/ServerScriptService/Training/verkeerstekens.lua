-- ModuleScript: ServerScriptService > Training > verkeerstekens
local descriptions = {
	"Voorrangsweg", "Einde voorrangsweg",
	"Verleen voorrang aan bestuurders op de kruisende weg",
	"Stop; verleen voorrang aan bestuurders op de kruisende weg",
}
local routes = { "Op de rijbaan.", "Op het pad bij dit bord." }

return {
	kind = "sign",
	questions = {
		{ id = "sign_b6_01", signCode = "B6", options = descriptions, correct = 3 },
		{ id = "sign_b1_01", signCode = "B1", options = descriptions, correct = 1 },
		{ id = "sign_b7_01", signCode = "B7", options = descriptions, correct = 4 },
		{ id = "sign_b2_01", signCode = "B2", options = descriptions, correct = 2 },
		{
			id = "sign_g11_01", signCode = "G11", options = routes, correct = 1,
			promptNl = "Je rijdt op een bromfiets met geel kenteken. Langs de rijbaan ligt alleen dit pad. Waar rijd je?",
			explanationNl = "Bij G11 mag je met deze bromfiets niet op het fietspad. Er is geen fiets/bromfietspad, dus je rijdt op de rijbaan.",
		},
		{
			id = "sign_g12a_01", signCode = "G12a", options = routes, correct = 2,
			promptNl = "Je rijdt op een bromfiets met geel kenteken. Je ziet dit bord bij het pad naast de rijbaan. Waar moet je rijden?",
			explanationNl = "Dit bord geeft een fiets/bromfietspad aan. Met je bromfiets moet je dat pad gebruiken.",
		},
		{
			id = "sign_g13_01", signCode = "G13", options = routes, correct = 1,
			promptNl = "Je rijdt op een snorfiets en laat de verbrandingsmotor aan. Naast de rijbaan ligt alleen dit pad. Waar rijd je?",
			explanationNl = "Met draaiende verbrandingsmotor mag je bij G13 niet het pad op. Zet je de motor uit, dan mag je het pad wel gebruiken.",
		},
	},
}
