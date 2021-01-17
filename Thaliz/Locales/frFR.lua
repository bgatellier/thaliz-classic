local L = LibStub("AceLocale-3.0"):NewLocale("Thaliz", "frFR")
if not L then return end

-- Nom des sorts de résurrection
L["Ancestral Spirit"] = "Esprit Ancestral"
L["Rebirth"] = "Renaissance"
L["Redemption"] = "Rédemption"
L["Resurrection"] = "Résurrection"

-- Messages de résurrection par défaut
-- %s sera remplacé par le nom du personnage ressuscité
-- %c sera remplacé par la classe du personnage
L["Default Messages"] = {
	-- UBRS
	"(Résurrection) CELA NE PEUT ÊTRE ! %p, occupez-vous de ces insectes !"									 	,	-- Seigneur Victor Nefarius
	-- ZG
	"(Résurrection) %p, je vous ai à l'œil !"										                         	,	-- Seigneur sanglant Mandokir
	"(Résurrection) %p, que ta RAGE m’envahisse !"                          									,	-- Grand prêtre Thekal
	"(Résurrection) Fuir ne vous servira à rien, %p !"										                 	,	-- Hakkar
	-- AQ20
	"(Résurrection) Maître %c %p, continuez le combat !"									                    ,	-- Général Rajaxx
	-- MC
	"(Résurrection) Vous avez sans doute besoin que je vous inflige quelques douleurs supplémentaires, %p !"	,	-- Chambellan Executus
	"(Résurrection) Trop tôt, %p ! Tu es mort trop tôt !"									                    ,	-- Ragnaros
	"(Résurrection) Vous m'avez trahi, %p ! Justice sera faite, en vérité !"									,	-- Ragnaros
	-- BWL
	"(Résurrection) Pardonnez-moi, %p ! Votre mort ne fait qu'ajouter à mon échec !"						    ,	-- Vaelastrasz le Corrompu
	-- AQ40
	"(Résurrection) Puisse votre mort servir d’exemple, %p !"										         	,	-- Le Prophète Skeram
	"(Résurrection) Seules la chair et les os. Les %cs sont des proies si faciles…"						     	,	-- Empereur Vek'lor
	"(Résurrection) Tes amis vont t'abandonner, %p."										                 	,	-- C'Thun
	-- Naxx
	"(Résurrection) Shhh, %p… Ce sera bientôt fini."											             	,	-- Anub'Rekhan
	"(Résurrection) Tuez %p au nom du maître !" 										                     	,	-- Grande veuve Faerlina
	"(Résurrection) Levez-vous, %p ! Levez-vous et combattez une fois encore !"			                     	,	-- Noth le Porte-peste
	"(Résurrection) Tu aurais dû rester chez toi, %p."									                     	,	-- Instructeur Razuvious
	"(Résurrection) La mort est la seule issue, %p !"									                     	,	-- Gothik le Moissonneur
	"(Résurrection) À moi la première résurrection ! Qui prend le pari ?"								     	,	-- Dame Blaumeux (Quatre Cavaliers)
	"(Résurrection) Plus jouer, %p ?"									                                     	,	-- Le Recousu
	"(Résurrection) %p, vous arrivez trop tard… Je… dois… OBÉIR !"									         	,	-- Thaddius
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
L["You can use %s and %c into your message. They will be replaced by the resurrected player's name and his class name."] = "Vous pouvez utiliser les caractères %p et %c. Ils seront remplacés par le nom du personnage ressuscité ainsi que le nom de sa classe."
L["Use it for"] = "L'utiliser pour"
L["who/which is"] = "qui est"
L["Druid"] = "Druide"
L["Hunter"] = "Chasseur"
L["Mage"] = "Mage"
L["Paladin"] = "Paladin"
L["Priest"] = "Prêtre"
L["Rogue"] = "Voleur"
L["Shaman"] = "Chaman"
L["Warlock"] = "Démoniste"
L["Warrior"] = "Guerrier"
L["Dwarf"] = "Nain"
L["Gnome"] = "Gnome"
L["Human"] = "Humain"
L["Night elf"] = "Elfe de la nuit"
L["Orc"] = "Orc"
L["Tauren"] = "Tauren"
L["Troll"] = "Troll"
L["Undead"] = "Mort-vivant"
L["Everyone"] = "Tout le monde"
L["a Guild"] = "une guilde"
L["a Character"] = "un personnage"
L["a Class"] = "une classe"
L["a Race"] = "une race"
L["Delete this message"] = "Supprimer ce message"
L["Private message"] = "Message privé"
L["About"] = "A propos"
L["Version %s"] = "Version %s"
L["By %s"] = "Par %s"
L["Created by %s, with the contribution of %s"] = "Créé par %s, avec la contribution de %s"
L["Download the latest version at %s"] = "Téléchargez la dernière version à l'adresse %s"
L["Debug"] = "Debug"
L["Function name"] = "Nom de la fonction"
L["Raid/party scan frequency"] = "Fréquence de scan du raid/groupe"
L["Frequency (in seconds) at which the raid or party is scanned for corpses to resurrect"] = "Fréquence en secondes à laquelle le raid ou groupe est scanné à la recherche de corps à ressusciter"
L["Configuration"] = "Configuration"
L["Show/Hide configuration options"] = "Afficher/masquer les options de configuration"
L["Version"] = "Version"
L["Displays Thaliz version"] = "Affiche la version de Thaliz"
L["version %s by %s"] = "version %s par %s"
