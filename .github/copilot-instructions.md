# Copilot-Anweisungen für dieses Repo

Kurz und präzise Hinweise, damit ein AI-Coding-Agent hier schnell produktiv wird.

- **Projektart:** Spring Boot (Maven) Web-Anwendung mit Thymeleaf-Template.
- **Wichtigste Dateien:**
  - `pom.xml` — Maven-Build, Java 17, `spring-boot-maven-plugin`.
  - `mvnw`, `mvnw.cmd` — Maven Wrapper (unter Windows `mvnw.cmd` verwenden).
  - `src/main/java/ch/bbw/archictecturerefcard01/ArchitectureRefCard01Application.java` — App-Einstiegspunkt.
  - `src/main/java/ch/bbw/archictecturerefcard01/HomeController.java` — liefert die Startseite (`GET ""`).
  - `src/main/java/ch/bbw/archictecturerefcard01/RestAPIController.java` — einfache API (`GET "api"`).
  - `src/main/resources/templates/index.html` — Thymeleaf-Template zeigt `message`.

Kurzer Überblick / Architektur
- Kleines monolithisches Spring Boot Web-App-Repository. Main-Artifact ist eine ausführbare JAR in `target/`.
- UI wird serverseitig gerendert (Thymeleaf). Zusätzlich gibt es eine sehr einfache JSON-API unter `/api`.
- Keine Datenbank, keine externe Services — Netzwerk-abhängig ist nur die Web-Auslieferung.

Entwickler-Workflows (konkret)
- Lokales Bauen (Windows PowerShell):
  ```powershell
  .\mvnw.cmd clean package
  java -jar target\app-refcard-01-0.0.1-SNAPSHOT.jar
  ```
  Die App ist dann unter `http://localhost:8080` erreichbar.
- Alternativ zum schnellen Starten in der Entwicklung:
  ```powershell
  .\mvnw.cmd spring-boot:run
  ```
- Docker (empfohlen: Dockerfile an Projekt-Root erstellen). Typische Befehle (PowerShell):
  ```powershell
  docker build -t <docker-user>/app-refcard-01:latest .
  docker run -p 8080:8080 <docker-user>/app-refcard-01:latest
  ```

CI/CD-Hinweise (GitHub Actions)
- Dieses Repo enthält noch keinen Workflow. Übliche Struktur: `.github/workflows/docker.yml`.
- Minimaler Workflow sollte die folgenden Schritte enthalten:
  - `actions/checkout@v4`
  - `actions/setup-java@v4` (Java 17)
  - Build: `./mvnw package` (Windows Runner: `mvnw.cmd` automatisch gehandhabt durch Actions)
  - Test: `./mvnw test`
  - Docker-Build & Push: `docker/build-push-action@v4` (Benutzer/Repo-Tagging) — setze Secrets `DOCKERHUB_USERNAME` + `DOCKERHUB_TOKEN`.
  - Optional: Push zusätzlich zu `ghcr.io` (GHCR) mit `GITHUB_TOKEN` oder PAT mit `write:packages`.

Projekt-spezifische Fallen / Beobachtungen
- `RestAPIController#hello` erstellt ein `Message message` und setzt Text, aber gibt am Ende `return ResponseEntity.ok(new Message());` zurück — das Ergebnis ist leer. Tests oder API-Verbraucher müssen mit dieser Inkonsistenz rechnen oder die Controller-Implementierung anpassen.
- Es gibt keine Unit-Tests im Repository, obwohl `spring-boot-starter-test` als Dependency vorhanden ist. CI sollte `mvn test` trotzdem ausführen (0 Tests → erfolgreicher Exit).
- `application.properties` ist leer; keine speziellen Profile/Ports konfiguriert. App nutzt Standard-Port `8080`.

Was ein Agent tun darf / nützliche Beispiele
- Wenn du eine Dockerfile-Vorlage erzeugst, verwende ein Multi-Stage-Build: erst Maven-Build (maven:3.8.6-openjdk-17), dann runtime JRE (z. B. `eclipse-temurin:17-jre`). Beispiel-Befehl:
  ```dockerfile
  # build stage
  FROM maven:3.8.6-openjdk-17 AS build
  COPY . /app
  WORKDIR /app
  RUN mvn -B -DskipTests package

  # runtime stage
  FROM eclipse-temurin:17-jre
  COPY --from=build /app/target/app-refcard-01-0.0.1-SNAPSHOT.jar /app/app.jar
  ENTRYPOINT ["java","-jar","/app/app.jar"]
  ```
- Wenn du CI/CD-Workflows schreibst, dokumentiere die erwarteten Secrets (`DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, optional `GHCR_TOKEN`) und nenne die erwartete Image-Tag-Strategie (`${{ github.repository_owner }}/app-refcard-01:${{ github.sha }}` oder `:latest`).
- Falls du Controller/REST änderst, vermerke in der Änderung, dass `RestAPIController` aktuell ein leeres `Message`-Objekt zurückgibt — das ist ein auffälliges, testrelevantes Verhalten.

Wann nachfragen
- Wenn du Tests schreibst: frage nach gewünschtem API-Output (soll `/api` die Message mit Server-IP zurückgeben?).
- Wenn du ein Image-Tagging- oder Release-Verhalten planst, frage nach dem DockerHub-Benutzernamen/Organisation und Push-Rechten.

Kurz: fokussiere dich zuerst auf `pom.xml`, `ArchitectureRefCard01Application`, `HomeController` und `RestAPIController` für Änderungen an Build oder API; benutze `mvnw.cmd` auf Windows; füge Workflow-Secrets in GitHub ein, bevor du Push-to-Registry aktivierst.

----
Wenn du willst, kann ich jetzt automatisch eine initiale `Dockerfile` und eine Beispiel-GitHub-Actions-Workflow-Datei (`.github/workflows/docker-publish.yml`) erzeugen. Soll ich das tun? Antwort: "Ja" oder "Nein / erst dokumentieren".
