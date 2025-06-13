class Spin < Formula
  desc "Open-source tool for building and running serverless WebAssembly applications"
  homepage "https://github.com/spinframework/spin"
  version "3.2.0"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/spinframework/spin/releases/download/v#{version}/spin-v#{version}-macos-amd64.tar.gz"
    sha256 "ec1d5d0790e350ca60da6d31162b5a9d80d3bb0ff773cb379734eb49ee5f28de"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/spinframework/spin/releases/download/v#{version}/spin-v#{version}-macos-aarch64.tar.gz"
    sha256 "151e0512fd99e8373fcd7ea3b9f4f25950a72c50f1bbd60ae2ff10e6384e0a2c"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/spinframework/spin/releases/download/v#{version}/spin-v#{version}-linux-amd64.tar.gz"
    sha256 "8823e9b533faf367a279e2d958c447e9c6f0ddd43ffae8c2e1bb09401cc76e98"
  end

  if OS.linux? && Hardware::CPU.arm?
    url "https://github.com/spinframework/spin/releases/download/v#{version}/spin-v#{version}-linux-aarch64.tar.gz"
    sha256 "a84b96cc0971333135d8c53ac55c2b621ebfa8f8b75d56193f0b3c73aef17559"
  end

  def install
    bin.install "spin"
  end

  def post_install
    # Migrate plugins and templates and templates data to new data directory
    source_dir = etc/"fermyon-spin"
    dest_dir = etc/"spinframework-spin"
    if File.directory?(source_dir) && !Dir.empty?(source_dir)
      ohai "Migrating Spin data from #{source_dir} to #{dest_dir}"
      mkdir_p dest_dir
      files = Dir.glob("#{source_dir}/*")

      if files.any?
        files.each do |file|
          cp_r file, dest_dir, preserve: true
        end
      else
        ohai "No files to migrate from #{source_dir}"
      end
    end

    # Install default templates and plugins for language tooling and deploying apps to the cloud.
    # Templates and plugins are installed into `pkgetc/"templates"` and `pkgetc/"plugins"`.
    system "#{bin}/spin", "templates", "install", "--git", "https://github.com/spinframework/spin", "--upgrade"
    system "#{bin}/spin", "templates", "install", "--git", "https://github.com/spinframework/spin-python-sdk", "--upgrade"
    system "#{bin}/spin", "templates", "install", "--git", "https://github.com/spinframework/spin-js-sdk", "--upgrade"
    system "#{bin}/spin", "plugins", "update"
    system "#{bin}/spin", "plugins", "install", "js2wasm", "--yes"
  end

  test do
    assert shell_output("#{bin}/spin --version").start_with?("spin #{version}")
  end
end
