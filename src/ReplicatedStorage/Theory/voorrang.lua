-- ModuleScript: ReplicatedStorage > Theory > voorrang
return {
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
