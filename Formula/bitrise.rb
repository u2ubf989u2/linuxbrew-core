class Bitrise < Formula
  desc "Command-line automation tool"
  homepage "https://github.com/bitrise-io/bitrise"
  url "https://github.com/bitrise-io/bitrise/archive/1.24.0.tar.gz"
  sha256 "ff332860961ac2f2109d696c95355f45cbd1f3fab054b8127689794708f11e52"

  bottle do
    cellar :any_skip_relocation
    sha256 "23fc86afd97a9a182459d26a76eb0835765edcb76a1fc5e64d7bed846ec4ec56" => :mojave
    sha256 "e90e6f28bae6457938d2bc7c751683c3c3254af3f7bbd1098bdde6290b0451fa" => :high_sierra
    sha256 "2eaa414b0c9240fbe8632718748ca485625f2dcb171d94cd3b1a650e9a1cedae" => :sierra
    sha256 "25da74264dca22d8c8958105b623570c19cac283336b08a003cf4696b1fa6a89" => :x86_64_linux
  end

  depends_on "go" => :build
  depends_on "rsync" => :test

  def install
    ENV["GOPATH"] = buildpath

    # Install bitrise
    bitrise_go_path = buildpath/"src/github.com/bitrise-io/bitrise"
    bitrise_go_path.install Dir["*"]

    cd bitrise_go_path do
      prefix.install_metafiles

      system "go", "build", "-o", bin/"bitrise"
    end
  end

  test do
    (testpath/"bitrise.yml").write <<~EOS
      format_version: 1.3.1
      default_step_lib_source: https://github.com/bitrise-io/bitrise-steplib.git
      workflows:
        test_wf:
          steps:
          - script:
              inputs:
              - content: printf 'Test - OK' > brew.test.file
    EOS

    system "#{bin}/bitrise", "setup"
    system "#{bin}/bitrise", "run", "test_wf"
    assert_equal "Test - OK", (testpath/"brew.test.file").read.chomp
  end
end
