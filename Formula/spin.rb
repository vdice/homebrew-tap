class Spin < Formula
  desc "Open-source tool for building and running serverless WebAssembly applications"
  homepage "https://developer.fermyon.com/spin"
  version "2.4.3-vdice-test2"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/fermyon/spin/releases/download/v#{version}/spin-v#{version}-macos-amd64.tar.gz"
    sha256 "9890375577cdafae7bf10db1c34c4e65c725a10a5e088b239f7755765b274d5b"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/fermyon/spin/releases/download/v#{version}/spin-v#{version}-macos-aarch64.tar.gz"
    sha256 "7fb4a5788fc0879106100c628a8939e5e6e562e7a337f560478d08a727f83843"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/fermyon/spin/releases/download/v#{version}/spin-v#{version}-linux-amd64.tar.gz"
    sha256 "47e83980e705fda16889baa956600e8c00794326af0cc30835ee739da0d4df6c"
  end

  if OS.linux? && Hardware::CPU.arm?
    url "https://github.com/fermyon/spin/releases/download/v#{version}/spin-v#{version}-linux-aarch64.tar.gz"
    sha256 "c3accf3c8d14450f78c5812507cc02243ccdaf72c04ee0342e5310d25414eace"
  end

  def install
    bin.install "spin"
  end

  def post_install
    # Install default templates and plugins for language tooling and deploying apps to the cloud.
    # Templates and plugins are installed into `pkgetc/"templates"` and `pkgetc/"plugins"`.
    system "#{bin}/spin", "templates", "install", "--git", "https://github.com/fermyon/spin", "--upgrade"
    system "#{bin}/spin", "templates", "install", "--git", "https://github.com/fermyon/spin-python-sdk", "--upgrade"
    system "#{bin}/spin", "templates", "install", "--git", "https://github.com/fermyon/spin-js-sdk", "--upgrade"
    system "#{bin}/spin", "plugins", "update"
    system "#{bin}/spin", "plugins", "install", "js2wasm", "--yes"
    system "#{bin}/spin", "plugins", "install", "cloud", "--yes"
  end

  test do
    assert shell_output("#{bin}/spin --version").start_with?("spin #{version}")
  end
end
