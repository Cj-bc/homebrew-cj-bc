class Vim < Formula
  desc "Vi 'workalike' with many additional features"
  homepage "https://www.vim.org/"
  # vim should only be updated every 50 releases on multiples of 50
  url "https://github.com/vim/vim/archive/v8.1.0650.tar.gz"
  sha256 "f734c283604f5889b3f62fec045b59f70b804165041370f2da1cbf8b0e0b4d9f"
  head "https://github.com/vim/vim.git"

  bottle do
    cellar :any
    sha256 "fdba5bbdcaf0ed52b7e77d6cca3cdb906a7c114af2e231622c65b10664a2154b" => :mojave
    sha256 "724d802a3a545c3a294a6abed460c883272e847d1ac227aae086b3c6b9ccdd9f" => :high_sierra
    sha256 "13dca85a2a07ebc225fbfcf473f216af62cd24174c4b2235a2cb0b62e46bf86a" => :sierra
  end

  depends_on "gettext" => :recommended
  #   option "without-nls", "Don't support NLS (gettext())"
  depends_on "lua" => :recommended
  depends_on "perl" => :recommended
  depends_on "python" => :recommended
  depends_on "python@2" => :recommended
  depends_on "ruby" => :recommended
  depends_on "cscope" => :recommended
  depends_on :x11 => :optional

  option "with-mzscheme", "Include MzScheme interpreter"
  option "with-workshop", "Include Sun Visual Workshop support"
  option "with-autoservername", "Automatically define servername at vim startup"
  option "with-multibyte", "Include multibyte editing support"
  option "with-hangulinput", "Include Hangul input support"
  option "with-xim", "Include XIM input support"
  option "with-fontset", "Include X fontset output support"
  option "with-x", "use the X Window System"

  option "without-terminal", "Disable terminal emulation support"
  option "without-netbeans", "Disable NetBeans integration support"
  option "without-channel", "Disable process communication support"
  option "without-rightleft", "Do not include Right-to-Left language support"
  option "without-arabic", "Do not include Arabic language support"
  option "without-farsi", "Do not include Farsi language support"
  option "without-largefile", "omit support for large files"
  option "without-acl", "No check for ACL support"
  option "without-gpm", "Don't use gpm (Linux mouse daemon)"
  option "without-sysmouse", "Don't use sysmouse (mouse in *BSD console)"


  conflicts_with "ex-vi",
    :because => "my-vim and ex-vi both install bin/ex and bin/view"

  conflicts_with "macvim",
    :because => "my-vim and macvim both install vi* binaries"
  conflicts_with "vim",
    :because => "my-vim and vim both install vi* binaries"

  def install
    ENV.prepend_path "PATH", Formula["python"].opt_libexec/"bin"

    # https://github.com/Homebrew/homebrew-core/pull/1046
    ENV.delete("SDKROOT")

    # vim doesn't require any Python package, unset PYTHONPATH.
    ENV.delete("PYTHONPATH")

    # set up configure options
    options=["--prefix=#{HOMEBREW_PREFIX}",
             "--mandir=#{man}",
             "--with-tlib=ncurses",
             "--with-compiledby=Homebrew"]

    if build.without?("gettext")
      options.push("--disable-nls")
    end

    if build.with?("lua")
      options.push("--enable-luainterp",
                   "--with-lua-prefix=#{Formula["lua"].opt_prefix}")
    end
    if build.with?("python")
      options.push("--enable-python3interp",
                   "--with-python-command=python3")
    end
    if build.with?("python@2")
      options.push("--enable-pythoninterp",
                   "--with-python-command=python")
    end
    if build.with?("perl")
      options.push("--enable-perlinterp")
    end
    if build.with?("ruby")
      options.push("--enable-rubyinterp")
    end
    if build.with?("cscope")
      options.push("--enable-cscope")
    end
    if build.with?("x11")
      options.push("--enable-gui")
    else
      options.push("--enable-gui=no")
    end
    if build.with? "mzscheme"
      options.push("--enable-mzschemeinterp")
    end
    if build.with? "workshop"
      options.push("--enable-workshop")
    end
    if build.with? "autoservername"
      options.push("--enable-autoservername")
    end
    if build.with? "multibyte"
      options.push("--enable-multibyte")
    end
    if build.with? "hangulinput"
      options.push("--enable-hangulinput")
    end
    if build.with? "xim"
      options.push("--enable-xim")
    end
    if build.with? "fontset"
      options.push("--enable-fontset")
    end
    if build.with? "x"
      options.push("--with-x")
    end
    if build.with? "terminal"
      options.push "--enable-terminal"
    end
    if build.without? "netbeans"
      options.push "--disable-netbeans"
    end
    if build.without? "arabic"
      options.push "--disable-arabic"
    end
    if build.without? "rightleft"
      options.push "--disable-rightleft"
    end
    if build.without? "channnel"
      options.push "--disable-channel"
    end
    if build.without? "farsi"
      options.push "--disable-farsi"
    end
    if build.without? "acl"
      options.push "--disable-acl"
    end
    if build.without? "gpm"
      options.push "--disable-gpm"
    end
    if build.without? "sysmouse"
      options.push "--disable-sysmouse"
    end
    if build.without? "largefile"
      options.push "--disable-largefile"
    end
    # We specify HOMEBREW_PREFIX as the prefix to make vim look in the
    # the right place (HOMEBREW_PREFIX/share/vim/{vimrc,vimfiles}) for
    # system vimscript files. We specify the normal installation prefix
    # when calling "make install".
    # Homebrew will use the first suitable Perl & Ruby in your PATH if you
    # build from source. Please don't attempt to hardcode either.
    system "./configure", *options

    system "make"
    # Parallel install could miss some symlinks
    # https://github.com/vim/vim/issues/1031
    ENV.deparallelize
    # If stripping the binaries is enabled, vim will segfault with
    # statically-linked interpreters like ruby
    # https://github.com/vim/vim/issues/114
    system "make", "install", "prefix=#{prefix}", "STRIP=#{which "true"}"
    bin.install_symlink "vim" => "vi"
  end

  test do
    (testpath/"commands.vim").write <<~EOS
      :python3 import vim; vim.current.buffer[0] = 'hello python3'
      :wq
    EOS
    system bin/"vim", "-T", "dumb", "-s", "commands.vim", "test.txt"
    assert_equal "hello python3", File.read("test.txt").chomp
    assert_match "+gettext", shell_output("#{bin}/vim --version")
  end
end
