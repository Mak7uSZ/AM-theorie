-- ModuleScript: ServerScriptService > Training > verkeerstekens
local descriptions = {
	"Voorrangsweg", "Einde voorrangsweg",
	"Verleen voorrang aan bestuurders op de kruisende weg",
	"Stop; verleen voorrang aan bestuurders op de kruisende weg",
}
local routes = { "Op de rijbaan.", "Op het pad bij dit bord." }
local access = { "Ja, ik mag hier inrijden.", "Nee, ik kies een andere route." }
local speeds = { "30 km/uur", "45 km/uur", "50 km/uur" }

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
		{
			id = "sign_c2_01", signCode = "C2", options = access, correct = 2,
			promptNl = "Je rijdt op een bromfiets. Dit bord is naar jou gericht en heeft geen onderbord. Mag je deze straat vanaf hier inrijden?",
			explanationNl = "C2 sluit de ingang af in jouw rijrichting. Dat geldt ook voor een bromfiets.",
		},
		{
			id = "sign_c13_01", signCode = "C13", correct = 1,
			options = { "De fietser.", "De bromfietser.", "Allebei." },
			promptNl = "Een fietser en een bromfietser met een werkende elektromotor naderen dit bord. Wie mag de weg inrijden?",
			explanationNl = "C13 geldt ook voor een bromfiets met een werkende elektromotor. Een gewone fiets mag hier wel rijden.",
		},
		{
			id = "sign_c15_01", signCode = "C15", options = access, correct = 2,
			promptNl = "Je wilt deze weg inrijden op je bromfiets met de motor uit. Bij de ingang staat alleen dit bord. Mag dat?",
			explanationNl = "C15 geldt ook voor een bromfiets met uitgeschakelde motor. Het bord geldt bovendien voor gewone fietsen.",
		},
		{
			id = "sign_a1_50_01", signCode = "A1-50", options = speeds, correct = 2,
			promptNl = "Je rijdt op de rijbaan op een bromfiets met geel kenteken. Hoe hard mag je maximaal rijden bij dit bord?",
			explanationNl = "Het bord geeft 50 km/uur aan. Voor je bromfiets geldt op de rijbaan het lagere maximum van 45 km/uur.",
		},
		{
			id = "sign_a2_30_01", signCode = "A2-30", options = speeds, correct = 2,
			promptNl = "Je passeert dit bord op de rijbaan met je bromfiets. Er geldt geen andere snelheidsbeperking. Wat is je maximum?",
			explanationNl = "De aangegeven limiet van 30 km/uur eindigt. Je maximum op de rijbaan is nu 45 km/uur.",
		},
		{
			id = "sign_zone_30_01", signCode = "A1-30-ZB", options = speeds, correct = 1,
			promptNl = "Na dit bord sla je rechtsaf. Je passeert geen bord einde zone. Hoe hard mag je maximaal rijden?",
			explanationNl = "De maximumsnelheid van 30 km/uur blijft binnen de zone gelden, ook als je afslaat.",
		},
		{
			id = "sign_end_zone_30_01", signCode = "A2-30-ZE", correct = 2,
			options = { "Pas bij het volgende kruispunt.", "Zodra ik dit bord passeer." },
			promptNl = "Je rijdt in een Zone 30 en nadert dit bord. Wanneer eindigt de zone?",
			explanationNl = "Je bent uit de zone zodra je dit bord passeert. Vanaf daar bepaal je welke limiet voor je voertuig en de weg geldt.",
		},
	},
}
