class MyVim < Formula
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
    ohai Generating configure options...
    options= %W[--prefix=#{HOMEBREW_PREFIX}
                --mandir=#{man}
                --with-tlib=ncurses
                --with-compiledby=Homebrew
               ]

    ohai "0/26"
    options << "--disable-nls" if build.without?("gettext")
    options << ["--enable-luainterp",
                "--with-lua-prefix=#{Formula["lua"].opt_prefix}"] if build.with?("lua")
    options << ["--enable-python3interp",
                "--with-python-command=python3"] if build.with?("python")
    options << ["--enable-pythoninterp",
                "--with-python-command=python"] if build.with?("python@2")
    options << "--enable-perlinterp" if build.with?("perl")
    options << "--enable-rubyinterp" if build.with?("ruby")
    options << "--enable-cscope" if build.with?("cscope")
    if build.with?("x11")
      options.push("--enable-gui")
    else
      options.push("--enable-gui=no")
    end
    options << "--enable-mzschemeinterp" if build.with? "mzscheme"
    options << "--enable-workshop" if build.with? "workshop"
    ohai "10/26"
    options << "--enable-autoservername" if build.with? "autoservername"
    options << "--enable-multibyte" if build.with? "multibyte"
    options << "--enable-hangulinput" if build.with? "hangulinput"
    options << "--enable-xim" if build.with? "xim"
    options << "--enable-fontset" if build.with? "fontset"
    options << "--with-x" if build.with? "x"
    options << "--enable-terminal" if build.with? "terminal"
    options << "--disable-netbeans" if build.without? "netbeans"
    options << "--disable-arabic" if build.without? "arabic"
    options << "--disable-rightleft" if build.without? "rightleft"
    ohai "20/26"
    options << "--disable-channel" if build.without? "channnel"
    options << "--disable-farsi" if build.without? "farsi"
    options << "--disable-acl" if build.without? "acl"
    options << "--disable-gpm" if build.without? "gpm"
    options << "--disable-sysmouse" if build.without? "sysmouse"
    options << "--disable-largefile" if build.without? "largefile"
    ohai "26/26"
    ohai "complete generating configure options"

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
