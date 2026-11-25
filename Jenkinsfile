pipeline {
    /*
     * Конвейер выполняется на Windows Agent,
     * которому присвоена метка windows-java21-agent.
     */
    agent any

    /*
     * Общие настройки Pipeline.
     */
    options {
        // Добавление временных меток в журнал.
        timestamps()

        // Запрет одновременного выполнения нескольких
        // сборок этого Pipeline.
        disableConcurrentBuilds()

        // Хранение последних 20 запусков.
        buildDiscarder(
            logRotator(numToKeepStr: '20')
        )
    }

    stages {

        /*
         * Этап 1. Получение исходного кода.
         */
        stage('Checkout') {
            steps {
                echo 'Получение исходного кода из Git'
                checkout scm
            }
        }

        /*
         * Этап 2. Проверка программного окружения.
         */
        stage('Toolchain') {
            steps {
                echo 'Проверка Java'
                bat 'java -version'

                echo 'Проверка Maven'
                bat 'mvn -version'

                echo 'Проверка Git'
                bat 'git --version'
            }
        }

        /*
         * Этап 3. Сборка приложения и выполнение тестов.
         *
         * Maven выполняет жизненный цикл до verify:
         * компиляцию, модульные и настроенные
         * интеграционные тесты.
         */
        stage('Build and Verify') {
            steps {
                echo 'Запуск полной проверки проекта'
                bat 'mvn -B -ntp clean verify'
            }
        }

        /*
         * Этап 4. Формирование дополнительных отчётов.
         */
        stage('Generate Reports') {
            steps {
                echo 'Формирование HTML-отчёта Surefire'
                bat 'mvn -B -ntp surefire-report:report-only'

                echo 'Формирование HTML-отчёта JaCoCo'
                bat 'mvn -B -ntp jacoco:report'
            }
        }

        stage('Main Release Candidate') {
            when {
                expression {
                    def branch = env.BRANCH_NAME ?: env.GIT_BRANCH ?: ''
                    return branch == 'master' || branch == 'origin/master'
                }
            }
            steps {
                echo "Ветка: ${env.BRANCH_NAME ?: env.GIT_BRANCH} - выполняется этап только для master"
                powershell '''
                    $jar = "target\\task-manager-cicd-1.0.0.jar"
                    if (-not (Test-Path $jar)) { throw "JAR не найден: $jar" }
                    $h = (Get-FileHash $jar -Algorithm SHA256).Hash
                    Write-Host "SHA-256: $h"
                    "$h  task-manager-cicd-1.0.0.jar" | Out-File target\\release-candidate.sha256 -Encoding ascii
                '''
                archiveArtifacts(
                    artifacts: 'target/task-manager-cicd-1.0.0.jar,target/release-candidate.sha256',
                    fingerprint: true
                )
            }
        }
    }

    /*
     * Действия после выполнения Pipeline.
     */
    post {

        /*
         * Публикация XML-отчётов тестирования
         * и архивирование диагностических материалов.
         */
        always {
            junit(
                allowEmptyResults: true,
                testResults: 'target/surefire-reports/TEST-*.xml,target/failsafe-reports/TEST-*.xml'
            )

            archiveArtifacts(
                artifacts: 'target/surefire-reports/**,target/failsafe-reports/**,target/site/**',
                allowEmptyArchive: true
            )
        }

        /*
         * JAR архивируется только при успешной сборке.
         */
        success {
            archiveArtifacts(
                artifacts: 'target/task-manager-cicd-1.0.0.jar',
                fingerprint: true
            )
        }

        failure {
            echo 'Pipeline завершился с ошибкой.'
            echo 'Необходимо изучить Console Output и отчёты.'
        }

        unstable {
            echo 'Pipeline имеет статус UNSTABLE.'
            echo 'Необходимо проверить результаты тестирования.'
        }
    }
}
