# EduConnect — Gestion d'Écoles & E-Learning (Flutter)

Application mobile Flutter construite d'après le *cahier de cadrage* et le document *Choix technologiques* :
trois profils (Étudiant, Enseignant, Administrateur) dont les fonctionnalités sont reliées entre elles.

## Lancer le projet
```bash
flutter create . --org edu.ecole --project-name ecole_elearning   # génère android/ ios/ (une seule fois)
flutter pub get
flutter run
```
Comptes de démonstration (boutons sur l'écran de connexion) :
| Profil | Email | Mot de passe |
|---|---|---|
| Étudiant | etudiant@ecole.edu | etud123 |
| Enseignant | prof@ecole.edu | prof123 |
| Administrateur | admin@ecole.edu | admin123 |

## Architecture
```
lib/
├── main.dart / app.dart          Point d'entrée, routage selon le rôle
├── core/                         Design system, thème et composants réutilisables
├── data/                         Modèles et état métier de démonstration
└── features/
    ├── auth/                     Connexion et validation des identifiants
    ├── shared/                   Navigation, notifications, emploi du temps, tuteur IA, profil
    ├── student/                  Accueil, cours, évaluations et paiements
    ├── teacher/                  Tableau de bord, cours, quiz, étudiants et notes
    └── admin/                    Dashboard, comptes, classes/cours, finances et annonces
```
`AppState` simule les services du cahier de cadrage (Auth, Academic, Media, Billing, Assessment, Notification).
Pour passer au back-end Spring Boot + Keycloak : remplacer le corps de ses méthodes par des appels REST
(JWT dans l'en-tête) vers la gateway ; les écrans n'ont pas à changer.

L'espace d'administration permet de créer des classes et des cours associés à un enseignant actif, puis de
retrouver les comptes par nom, email ou classe. Les données et les accès de démonstration restent stockés
uniquement en mémoire : ils ne constituent pas un système d'authentification ni une base de production.

## Liens entre les profils
- L'enseignant publie un cours / contenu / quiz → l'étudiant de la classe le voit et reçoit une notification.
- L'étudiant passe un quiz → correction automatique → note dans son relevé → l'enseignant voit la soumission et les statistiques d'erreurs par question.
- L'enseignant saisit une note → notification + moyenne mise à jour côté étudiant.
- L'admin émet une facture → l'étudiant paie (Mobile Money simulé, confirmation après vérification) → reçu ; l'admin voit la transaction, l'enseignant voit seulement le statut.
- L'admin crée/suspend des comptes (la connexion en tient compte), planifie l'emploi du temps et diffuse des annonces ciblées.

## Innovations du cahier de cadrage
- **Hors connexion** : téléchargement de contenus, quiz mis en file puis synchronisés (Plus → Mode hors connexion).
- **Notifications intelligentes** ciblées par rôle, classe ou utilisateur.
- **Tuteur IA** (réponses simulées) et chapitres à réviser.
- **Anti-triche** : alertes si l'étudiant quitte l'application pendant un quiz (simulation du proctoring).

## Prochaines étapes (versions 2 et 3)
Brancher `http`/`dio` + Keycloak, `video_player` (HLS), `firebase_messaging`, stockage local (`drift`/`hive`), vrai fournisseur Mobile Money.
# Gestion_D-ecole_et_E_learning_APP_Mobile
