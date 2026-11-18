-- ModuleScript: ReplicatedStorage > TopicContent
-- Public content only. Never store answer keys in ReplicatedStorage.
local voorrang = {
	topicId = "voorrang",
	titleNl = "Voorrang",
	sourceName = "RVV 1990",
	sourceUrl = "https://wetten.overheid.nl/BWBR0004825/",
	article = "1; 2 lid 2; 15; 54; 62–64",
	reviewStatus = "awaiting_review",
	-- Image IDs imported by the owner. Page imageKey fields below stay symbolic.
	images = {
		bestuurders = "79269872017289",
		rechts = "115675391659452",
		onverhard = "104954906824814",
		tram = "108839172162301",
	},
	questionIds = { "cyclist_right_01", "unpaved_01", "tram_demo_01" },
	sceneIds = { "CyclistRight01", "UnpavedRoad01", "TramCrossing01" },
	pages = {
		{
			titleNl = "Bestuurders en weggebruikers",
			text = "Het is belangrijk om het verschil tussen bestuurders en voetgangers te kennen. Ze zijn allebei weggebruikers, maar sommige verkeersregels gelden alleen voor bestuurders.\n\nBestuurders zijn alle weggebruikers behalve voetgangers.",
			imageKey = "bestuurders",
			captionNl = "Links: voetganger. Rechts: bestuurder. Allebei zijn ze weggebruikers.",
		},
		{
			titleNl = "Lopen of fietsen?",
			text = "Iemand die met een fiets aan de hand op het trottoir loopt, is een voetganger: wel een weggebruiker, maar geen bestuurder.\n\nIemand die op het fietspad fietst, is zowel een bestuurder als een weggebruiker.",
			imageKey = "bestuurders",
			captionNl = "Het verschil zit in lopen met de fiets of erop rijden.",
		},
		{
			titleNl = "Een gelijkwaardig kruispunt herkennen",
			text = "Bij een gelijkwaardig kruispunt is de voorrang niet geregeld met voorrangsborden of haaientanden.\n\nIn deze uitleg gaan we uit van een kruispunt zonder werkende verkeerslichten of aanwijzingen van een verkeersregelaar, waar twee verharde wegen elkaar kruisen. Het gaat niet om een uitrit.",
			imageKey = "rechts",
			captionNl = "Voorbeeldsituatie: twee verharde wegen, zonder voorrangsregeling.",
		},
		{
			titleNl = "Bestuurders van rechts",
			text = "Ook als bromfietser verleen je op een gelijkwaardig kruispunt voorrang aan bestuurders die voor jou van rechts komen.\n\nVoorbeeld: van rechts komt een fietser op de kruisende verharde weg. Je verleent de fietser voorrang, omdat de fietser een bestuurder is die voor jou van rechts komt.",
			imageKey = "rechts",
			captionNl = "De fietser komt van rechts voor de bromfietser.",
		},
		{
			titleNl = "Uitzondering: onverharde weg",
			text = "Twee uitzonderingen op de hoofdregel van artikel 15:\n\n1. Bestuurders op een onverharde weg verlenen voorrang aan bestuurders op een verharde weg.\n\nOok als de bestuurder op de verharde weg van links komt.",
			imageKey = "onverhard",
			captionNl = "De bromfietser rijdt op onverhard; de auto rijdt op de verharde weg.",
		},
		{
			titleNl = "Uitzondering: tram",
			text = "2. Bestuurders verlenen voorrang aan bestuurders van een tram, ook als de tram van links komt.\n\nDeze uitzonderingen horen bij de hoofdregel voor kruispunten. Voorrangsborden, verkeerslichten en aanwijzingen kunnen een andere regeling geven. Een tram heeft dus niet in iedere situatie voorrang.",
			imageKey = "tram",
			captionNl = "Deze afbeelding toont een kruispunt zonder voorrangsregeling.",
		},
	},
}

local verkeerstekens = {
	topicId = "verkeerstekens",
	titleNl = "Verkeerstekens",
	sourceName = "RVV 1990 — bijlage 1",
	sourceUrl = "https://wetten.overheid.nl/BWBR0004825/#Bijlage1",
	article = "Bijlage 1, B1/B2/B6/B7 en artikelen 15, 18, 62–64, 79, 84",
	reviewStatus = "reviewed",
	images = {},
	questionIds = { "sign_b6_01", "sign_b1_01", "sign_b7_01", "sign_b2_01" },
	sceneIds = {},
	-- The owner's first four sign explanations, edited and checked against the RVV.
	pages = {
		{
			titleNl = "B1 — Voorrangsweg",
			text = "B1 geeft aan dat je op een voorrangsweg rijdt. Bestuurders uit zijwegen verlenen jou voorrang. Als je afslaat, gelden ook de regels voor afslaan. Volg de verkeerslichten en de aanwijzingen van een verkeersregelaar.\n\nVoorbeeld: je rijdt rechtdoor op je bromfiets. Een auto komt uit een zijweg van rechts. De automobilist moet jou voorrang verlenen. Rijd pas door als het veilig is.",
			signCode = "B1", captionNl = "Schematische tekening. Bronlabel: RVV 1990, bijlage 1.",
		},
		{
			titleNl = "B2 — Einde voorrangsweg",
			text = "Bord B2 geeft aan dat de voorrangsweg eindigt. Bij het volgende kruispunt kijk je opnieuw welke voorrangsregels en verkeerstekens daar gelden.\n\nVoorbeeld: na B2 nader je op je bromfiets een gelijkwaardig kruispunt. Er komt een auto van rechts. Je verleent de automobilist voorrang.",
			signCode = "B2", captionNl = "De drie diagonale strepen onderscheiden dit bord van B1.",
		},
		{
			titleNl = "B6 — Voorrang verlenen",
			text = "Bij B6 verleen je voorrang aan bestuurders op de kruisende weg, zowel van links als van rechts. Je mindert vaart en stopt als dat nodig is. Als het kruispunt vrij is en je veilig kunt oversteken, mag je doorrijden.\n\nVoorbeeld: een auto komt van links. Hoewel jij voor die auto van rechts komt, verleen je de automobilist voorrang vanwege B6.",
			signCode = "B6", captionNl = "Schematische tekening. Bronlabel: RVV 1990, bijlage 1.",
		},
		{
			titleNl = "B7 — Stop en verleen voorrang",
			text = "Bij B7 kom je eerst volledig tot stilstand. Is er een stopstreep voor jou, dan stop je ervoor. Daarna verleen je voorrang aan bestuurders op de kruisende weg.\n\nVoorbeeld: je nadert op je bromfiets een leeg kruispunt. Bij B6 mag je doorrijden als het veilig is. Bij B7 moet je ook op een leeg kruispunt eerst stoppen.",
			signCode = "B7", captionNl = "Het woord STOP maakt deel uit van de tekening van het bord.",
		},
	},
}

return {
	defaultTopicId = "voorrang",
	order = { "voorrang", "verkeerstekens" },
	topics = { voorrang = voorrang, verkeerstekens = verkeerstekens },
}
