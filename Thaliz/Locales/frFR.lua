local L = LibStub("AceLocale-3.0"):NewLocale("Thaliz", "frFR")
if not L then return end

-- Resurrection spell name
L["Ancestral Spirit"] = "Esprit Ancestral"
L["Rebirth"] = "Renaissance"
L["Redemption"] = "Rédemption"
L["Resurrection"] = "Résurrection"

--  Default resurrection messages
L["Default Messages"] = {
	-- UBRS
	"(Résurrection) CELA NE PEUT ÊTRE ! %s, occupez-vous de ces insectes !"									 ,	-- Lord Victor Nefarius
	-- ZG
	"(Résurrection) %s, je vous ai à l'œil !"										                         ,	-- Seigneur sanglant Mandokir
	"(Résurrection) %s, que ta RAGE m’envahisse !"                          									 ,	-- Grand prêtre Thekal
	"(Résurrection) Fuir ne vous servira à rien, %s !"										                 ,	-- Hakkar
	-- AQ20
	"(Résurrection) Maître %c %s, continuez le combat !"									                     ,	-- Général Rajaxx
	-- MC
	"(Résurrection) Vous avez sans doute besoin que je vous inflige quelques douleurs supplémentaires, %s !"	 ,	-- Chambellan Executus
	"(Résurrection) Top tôt, %s ! Tu es mort trop tôt !"									                     ,	-- Ragnaros
	"(Résurrection) Vous m'avez trahi, %s ! Justice sera faite, en vérité !"									 ,	-- Ragnaros
	-- BWL
	"(Résurrection) Pardonnez-moi, %s ! Votre mort ne fait qu'ajouter à mon échec !"						     ,	-- Vaelastrasz le Corrompu
	-- AQ40
	"(Résurrection) Puisse votre mort servir d’exemple, %s !"										         ,	-- Le Prophète Skeram
	"(Résurrection) Seules la chair et les os. Les %cs sont des proies si faciles…"						     ,	-- Empereur Vek'lor
	"(Résurrection) Tes amis vont t'abandonner, %s."										                     ,	-- C'Thun
	-- Naxx
	"(Résurrection) Chut, %s… Ce sera bientôt fini."											                 ,	-- Anub'Rekhan
	"(Résurrection) Tuez %s au nom du maître !" 										                         ,	-- Grande veuve Faerlina
	"(Résurrection) Levez-vous, %s ! Levez-vous et combattez une fois encore !"			                     ,	-- Noth le Porte-peste
	"(Résurrection) Tu aurais dû rester chez toi, %s."									                     ,	-- Instructeur Razuvious
	"(Résurrection) La mort est la seule issue, %s !"									                     ,	-- Gothik le Moissonneur
	"(Résurrection) À moi la première résurrection ! Qui prend le pari ?"								     ,	-- Dame Blaumeux (Quatre Cavaliers)
	"(Résurrection) On joue plus, %s ?"									                                     ,	-- Le Recousu
	"(Résurrection) %s, vous arrivez trop tard… Je… dois… OBÉIR !"									         ,	-- Thaddius
}

L["Resurrection incoming in 10 seconds!"] = "Résurrection dans 10 secondes !"
L["None"] = "Aucune"

-- Options
L["Public Messages"] = "Messages publics"
L["Enabled"] = "Activé"
L["Broadcast channel"] = "Canal de diffusion"
L["Raid/Party"] = "Raid/Groupe"
L["Say"] = "Dire"
L["Yell"] = "Crier"
L["Add messages for everyone to the list of targeted messages"] = "Inclure les messages à destination de tout le monde aux messages spécifiques (classe, personnage…)"
L["Messages"] = "Messages"
L["Add a new message"] = "Ajouter un nouveau message"
L["Once your message has been added, you can change its group and group value."] = "Une fois que le message a été ajouté, vous pourrez choisir à qui il est destiné."
L["Message"] = "Message"
L["Use it for"] = "L'utiliser pour"
L["who/which is"] = "qui est"
L["Everyone"] = "Tout le monde"
L["a Guild"] = "une guilde"
L["a Character"] = "un personnage"
L["a Class"] = "une classe"
L["a Race"] = "une race"
L["For the class or race selector use the english language (e.g. hunter, dwarf...)"] = "Pour le sélecteur de classe et de race, utilisez la langue anglaise (par exemple : hunter, dwarf…)"
L["Delete this message"] = "Supprimer ce message"
L["Private message"] = "Message privé"
L["About"] = "A propos"
L["Version %s"] = "Version %s"
L["By %s"] = "Par %s"
L["Download the latest version at %s"] = "Télécharger la dernière version à l'adresse %s"
L["Debug"] = "Debug"
L["Function name"] = "Nom de la fonction"
L["Raid/party scan frequency"] = "Fréquence de scan du raid/groupe"
L["Frequency (in seconds) at which the raid or party is scanned for corpses to resurrect"] = "Fréquence en secondes à laquelle le raid ou groupe est scanné à la recherche de corps à ressusciter"
L["Configuration"] = "Configuration"
L["Show/Hide configuration options"] = "Afficher/masquer les options de configuration"
L["Version"] = "Version"
L["Displays Thaliz version"] = "Affiche la version de Thaliz"
L["version %s by %s"] = "version %s par %s"
