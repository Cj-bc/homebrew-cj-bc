class Code2img < Formula
  homepage "https://github.com/skanehira/code2img"
  version "1.2.0"
  url "https://github.com/skanehira/code2img/archive/v#{version}.tar.gz"
  desc "Generating image from source code"
  sha256 "3c49086678dcba9bbc4cb69338e4ac1a2032858ea9705806a2af1ffd7400888c"
  head "https://github.com/skanehira/code2img.git"

  depends_on "go"

  def install
    system "make", "build"
    bin.install "code2img"
  end

end
