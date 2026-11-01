# EduConnect — Gestion d'Écoles & E-Learning (Flutter)

Application mobile/web Flutter construite d'après un **cahier de cadrage** et un document de **choix technologiques** :
trois profils (Étudiant, Enseignant, Administrateur) dont les fonctionnalités sont reliées entre elles.
Le projet fonctionne aujourd'hui en **mode démonstration locale** (données en mémoire) avec une architecture prête pour un back-end REST.

---

## 1. Cahier des charges

### 1.1 Objectif
Fournir une plateforme unique de gestion scolaire et d'e-learning couvrant l'académique, les évaluations, les présences, les finances et la communication, pour trois profils d'utilisateurs.

### 1.2 Acteurs
| Acteur | Rôle |
|---|---|
| Étudiant | Consulte cours/quiz/devoirs, passe les quiz, dépose les devoirs, paie les frais, consulte notes/présences/bulletin. |
| Enseignant | Publie cours/contenus/quiz/devoirs, corrige, saisit les notes, marque les présences, suit les statistiques. |
| Administrateur | Gère comptes, classes, cours, emplois du temps, inscriptions, finances, annonces. |

### 1.3 Exigences fonctionnelles par profil

#### Étudiant
- Accueil : moyenne, quiz à faire, prochain cours, notes récentes, rappels.
- Cours : consultation vidéos/PDF/liens visio, progression, téléchargement hors ligne.
- Évaluations : passage de quiz (QCM auto-corrigés sur 20), consultation du bulletin et de la moyenne.
- Devoirs : dépôt de travail (texte, fichiers, liens), versions, hors ligne, statut, note et feedback.
- Paiements : factures, paiement Mobile Money simulé, reçus téléchargeables avec QR code, bourses.
- Présences : historique et taux d'assiduité.
- Notifications, messagerie, tuteur IA, paramètres (thème, langue).

#### Enseignant
- Tableau de bord : stats (cours, quiz, soumissions, étudiants), cours à venir, quiz à corriger.
- Cours : création/publication, leçons (vidéo/PDF/photo/lien visio), progression.
- Documents : partage.
- Quiz : création (cours, titre, échéance, questions QCM), rendus, statistiques d'erreurs par question.
- Devoirs : création (titre, cours, description, date/heure limite, type de remise, pénalité, groupe, rubrique), correction (note par critère, feedback, IA), statistiques, anti-plagiat, export CSV.
- Étudiants : liste par classe, inscriptions.
- Notes : saisie manuelle, relevé unifié.
- Présences : marquage par classe et date.
- Analytique : taux de réussite, soumissions.
- Messagerie/notifications/annonces.

#### Administrateur
- Dashboard : stats globales (comptes, cours, finances, présences).
- Comptes : créer/suspendre étudiants, enseignants, admins.
- Académique : classes, cours, affectation enseignants, inscriptions étudiants, emploi du temps, détection de conflits.
- Finances : factures, paiements, reçus, bourses/remises, tableau financier.
- Annonces : publication ciblée par rôle/classe/utilisateur.

### 1.4 Exigences non fonctionnelles
- **Offline-first** : téléchargement de contenus, file de synchronisation pour quiz/devoirs.
- **Notifications ciblées** : par rôle, classe, utilisateur.
- **Accessibilité** : thème clair/sombre, contraste élevé, taille de texte réglable, réduction des animations.
- **Internationalisation** : français / anglais.
- **Sécurité** : JWT (prévu), rôles, contrôle d'accès par profil.
- **Performance** : chargement asynchrone, pagination prévue côté API.

### 1.5 Règles métier clés
- Un quiz est rattaché à un cours existant ; correction automatique sur 20.
- Un devoir ne peut plus être déposé après l'échéance (fermeture automatique).
- Pénalité de retard automatique configurable.
- Les notifications sont envoyées aux étudiants de la classe concernée.
- Les paiements Mobile Money sont simulés (vérification 2s) puis reçu généré.
- Les bourses réduisent le montant dû.

---

## 2. Choix technologiques

### 2.1 Stack principale
| Couche | Technologie |
|---|---|
| Framework UI | Flutter (Dart) |
| Gestion d'état | Provider (`AppState`) |
| Routage | Routage par rôle (shells par profil) |
| Typographie | Google Fonts (Inter) |
| Internationalisation | `flutter_localizations` + `intl` |

### 2.2 Packages utilisés
| Package | Usage |
|---|---|
| `provider` | État global et injection de dépendances |
| `video_player` | Lecture vidéo HLS/MP4 (cours) |
| `http` | Client API REST (back-end Spring Boot / Django) |
| `google_fonts` | Typographie |
| `file_picker` | Sélection de fichiers (dépôts) |
| `path_provider` | Stockage local (reçus, téléchargements) |
| `share_plus` | Partage de reçus/contenus |
| `qr_flutter` | QR code sur les reçus |
| `flutter_pdfview` | Prévisualisation PDF |
| `path` | Manipulation de chemins |
| `shared_preferences` | Préférences locales (thème, langue) |
| `intl` + `flutter_localizations` | i18n (FR/EN) |

### 2.3 Back-end prévu
- API REST (Spring Boot / Django) avec authentification JWT (Keycloak).
- Gateway + services : Auth, Academic, Media, Billing, Assessment, Notification, Messaging, Assignments, Attendance, Scholarships, Analytics.
- `AppState` simule ces services ; remplacer le corps de ses méthodes par des appels REST sans changer les écrans.

### 2.4 Mode démonstration (actuel)
- Données stockées en mémoire dans `AppState`.
- Comptes de démo : étudiant, enseignant, administrateur.
- Repli local si le serveur est injoignable (création de cours, etc.).
- Notifications et paiements simulés.

### 2.5 Cibles de déploiement
- Android (AAB), iOS (IPA), Web (PWA).

---

## 3. Architecture

```
lib/
├── main.dart / app.dart          Point d'entrée, routage selon le rôle
├── core/                         Design system, thème, composants réutilisables
├── data/                         Modèles et état métier (AppState)
└── features/
    ├── auth/                     Connexion et validation des identifiants
    ├── shared/                   Navigation, notifications, emploi du temps, tuteur IA, profil, messagerie, paramètres
    ├── student/                  Accueil, cours, évaluations, devoirs, paiements, présences, bulletin, reçus
    ├── teacher/                  Tableau de bord, cours, documents, quiz, devoirs, étudiants, notes, analytique, présences
    └── admin/                    Dashboard, comptes, classes/cours, finances, annonces, inscriptions, conflits emploi du temps
```

---

## 4. Lancer le projet

```bash
flutter pub get
flutter run                                    # application complète (admin inclus)
flutter run -d web-server --web-port 8080 --web-hostname localhost  # serveur web local
flutter run -t lib/main_student.dart           # espace étudiant seul
flutter run -t lib/main_teacher.dart           # espace enseignant seul
flutter test                                   # tests
```

Comptes de démonstration :
| Profil | Email | Mot de passe |
|---|---|---|
| Étudiant | etudiant@ecole.edu | etud123 |
| Enseignant | prof@ecole.edu | prof123 |
| Administrateur | admin@ecole.edu | admin123 |

---

## 5. Liens entre les profils

- L'enseignant publie un cours / contenu / quiz / devoir → l'étudiant de la classe le voit et reçoit une notification.
- L'étudiant passe un quiz → correction automatique → note dans son relevé → l'enseignant voit la soumission et les statistiques.
- L'étudiant dépose un devoir → l'enseignant corrige (note + feedback) → notification + mise à jour du bulletin.
- L'enseignant saisit une note manuelle → notification + moyenne mise à jour.
- L'admin émet une facture → l'étudiant paie (Mobile Money simulé) → reçu ; l'admin voit la transaction.
- L'admin crée/suspend des comptes, planifie l'emploi du temps, gère les inscriptions, diffuse des annonces ciblées.
- Messagerie directe : étudiant ↔ enseignant ↔ admin, et messagerie de classe.

---

## 6. Innovations

- Hors connexion : téléchargement de contenus, quiz et devoirs mis en file puis synchronisés.
- Notifications intelligentes ciblées par rôle, classe ou utilisateur.
- Tuteur IA (réponses simulées + recommandations personnalisées).
- Anti-triche : alertes si l'étudiant quitte l'application pendant un quiz.
- Détection des conflits d'emploi du temps.
- Anti-plagiat : indice de similitude entre soumissions.
- Correction par rubrique pondérée + suggestion IA de feedback.
- Rappels automatiques et notification de retard pour les devoirs.
- Travail de groupe avec contributeurs tracés.
- Reçu de paiement avec QR code.

---

## 7. Design system « Neumorphism »

- Palette claire/sombre pilotée par `ThemeExtension` (`NeumoPalette`).
- `NeumoSurface` : carte neumorphique (ombre double).
- Champs de saisie en variante « enfoncée » (inset).
- `Neumo.of(context)` donne accès à la palette courante.

---

## 8. Paramètres

- Mode sombre, contraste élevé, réduction des animations, taille du texte.
- Langue : français / anglais.

---

## 9. Tests

```bash
flutter test
```

Couvre : administration académique (création classe/cours, contrôles d'accès, doublons).

---

## 10. Prochaines étapes pour production

1. Brancher `http`/`dio` + Keycloak (JWT, refresh tokens)
2. Remplacer `AppState` par appels REST vers la gateway
3. `video_player` : HLS natif + DRM si requis
4. `firebase_messaging` / FCM pour notifications push réelles
5. Stockage local persistant : `drift` (SQLite) ou `hive`
6. Vrai fournisseur Mobile Money (API opérateur, webhooks)
7. CI/CD : build Android (AAB) / iOS (IPA) / Web (PWA)
8. Tests d'intégration + golden tests UI

---

## Captures d'écran

![Écran d'accueil](flutter_01.png)
![Espace étudiant](flutter_02.png)
