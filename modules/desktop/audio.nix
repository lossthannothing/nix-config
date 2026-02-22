# modules/desktop/audio.nix
#
# PipeWire audio stack - replaces PulseAudio
# ALSA + PulseAudio compat + rtkit for realtime scheduling
{
  flake.modules.nixos.audio = {
    # Realtime scheduling for audio
    security.rtkit.enable = true;

    # PipeWire as the sound server
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Ensure PulseAudio is disabled (conflicts with PipeWire)
    services.pulseaudio.enable = false;
  };
}
