class Vidsheet < Formula
  desc "Local Synthesia-to-sheet-music tool (engine + web UI)"
  homepage "https://github.com/qwelpl/vidsheet-v2"
  url "https://github.com/qwelpl/vidsheet-v2/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "b6820306ebe17bf788f23fb739e5c0f67d5d315b639eeda282ed6b9f9075f25a"

  depends_on "ffmpeg"
  depends_on "node"
  depends_on "python@3.12"
  depends_on "yt-dlp"

  def install
    libexec.install Dir["*"]
    (libexec/"vidsheet").chmod 0555

    # Wrapper puts the brewed dependencies on PATH and points the launcher at
    # its read-only source in libexec. The launcher mirrors that into a writable
    # per-user data dir and builds the venv / web deps there on first run.
    dep_bins = %w[python@3.12 node ffmpeg yt-dlp].map { |f| formula_opt_bin(f) }
    (bin/"vidsheet").write <<~SH
      #!/bin/bash
      export VIDSHEET_SRC="#{libexec}"
      export PATH="#{dep_bins.join(":")}:$PATH"
      exec "#{libexec}/vidsheet" "$@"
    SH
    (bin/"vidsheet").chmod 0555
  end

  def caveats
    <<~EOS
      On first run, vidsheet copies itself into
        ~/.local/share/vidsheet
      and builds a Python venv and the web dependencies there. That first run
      needs internet access and a few hundred MB of free disk.

      Usage:
        vidsheet                     start the app, open it in your browser
        vidsheet <url|file>          start the app and analyze that source
        vidsheet analyze <url|file>  headless: write MIDI/CSV/MusicXML to --out
    EOS
  end

  test do
    assert_match "vidsheet", shell_output("#{bin}/vidsheet --help")
  end
end
