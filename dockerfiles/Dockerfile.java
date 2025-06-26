# Java Development Profile
FROM claude-code-docker:base

# Als root für Installationen
USER root

# Java und Build Tools
RUN sudo apt-get update && sudo apt-get install -y \
    openjdk-17-jdk \
    openjdk-11-jdk \
    maven \
    gradle \
    ant \
    && sudo rm -rf /var/lib/apt/lists/*

# Java Version Management - als claude user
USER claude
RUN curl -s "https://get.sdkman.io" | bash \
    && echo 'source "$HOME/.sdkman/bin/sdkman-init.sh"' >> ~/.bashrc
USER root

# Kotlin
RUN cd /tmp \
    && wget https://github.com/JetBrains/kotlin/releases/download/v1.9.22/kotlin-compiler-1.9.22.zip \
    && sudo unzip kotlin-compiler-1.9.22.zip -d /opt \
    && sudo chmod +x /opt/kotlinc/bin/* \
    && echo 'export PATH="/opt/kotlinc/bin:$PATH"' >> /home/claude/.bashrc \
    && rm kotlin-compiler-1.9.22.zip

# Scala und SBT
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list \
    && echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list \
    && curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add \
    && sudo apt-get update && sudo apt-get install -y sbt scala \
    && sudo rm -rf /var/lib/apt/lists/*

# Spring Boot CLI
RUN wget https://repo.spring.io/release/org/springframework/boot/spring-boot-cli/3.2.0/spring-boot-cli-3.2.0-bin.tar.gz \
    && sudo tar -xzf spring-boot-cli-3.2.0-bin.tar.gz -C /opt \
    && sudo ln -s /opt/spring-3.2.0/bin/spring /usr/local/bin/spring \
    && rm spring-boot-cli-3.2.0-bin.tar.gz

# Quarkus CLI
RUN curl -Ls https://sh.jbang.dev | bash -s - trust add https://repo1.maven.org/maven2/io/quarkus/quarkus-cli/ \
    && curl -Ls https://sh.jbang.dev | bash -s - app install --fresh --force quarkus@quarkusio

# GraalVM für Native Image
RUN wget https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-22.3.3/graalvm-ce-java17-linux-amd64-22.3.3.tar.gz \
    && sudo tar -xzf graalvm-ce-java17-linux-amd64-22.3.3.tar.gz -C /opt \
    && rm graalvm-ce-java17-linux-amd64-22.3.3.tar.gz \
    && echo 'export GRAALVM_HOME="/opt/graalvm-ce-java17-22.3.3"' >> /home/claude/.bashrc \
    && echo 'export PATH="$GRAALVM_HOME/bin:$PATH"' >> /home/claude/.bashrc

# Development Tools
RUN sudo apt-get update && sudo apt-get install -y \
    # Debugging
    gdb \
    valgrind \
    # Performance
    jmeter \
    && sudo rm -rf /var/lib/apt/lists/*

# IntelliJ IDEA Community Edition (headless for code analysis)
RUN wget https://download.jetbrains.com/idea/ideaIC-2023.3.2.tar.gz \
    && sudo tar -xzf ideaIC-2023.3.2.tar.gz -C /opt \
    && rm ideaIC-2023.3.2.tar.gz \
    && sudo ln -s /opt/idea-IC-*/bin/idea.sh /usr/local/bin/idea

# Java Linting und Code Quality
RUN wget https://github.com/checkstyle/checkstyle/releases/download/checkstyle-10.12.6/checkstyle-10.12.6-all.jar -O /opt/checkstyle.jar \
    && wget https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0-rc4/pmd-dist-7.0.0-rc4-bin.zip \
    && sudo unzip pmd-dist-7.0.0-rc4-bin.zip -d /opt \
    && rm pmd-dist-7.0.0-rc4-bin.zip \
    && sudo chmod +x /opt/pmd-bin-*/bin/pmd

# Testing Frameworks (via Maven/Gradle dependencies)
# JUnit, TestNG, Mockito, etc. werden projektspezifisch installiert

# Profil-spezifische Konfiguration
ENV CLAUDE_PROFILE=java
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Zurück zu claude user
USER claude
WORKDIR /home/claude