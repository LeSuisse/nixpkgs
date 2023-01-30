{ config, lib, pkgs, options }:

with lib;

let
  cfg = config.services.prometheus.exporters.shelly;
in
{
  extraOpts = {
    listen-address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      example = "127.0.0.1";
      description = lib.mdDoc ''
        The address to listen on for HTTP requests
      '';
    };
    listen-port = mkOption {
      type = types.port;
      default = 9784;
      example = 9784;
      description = lib.mdDoc ''
        The port to listen on for HTTP requests
      '';
    };
    metrics-file = mkOption {
      type = types.path;
      description = lib.mdDoc ''
        Path to the JSON file with the metric definitions
      '';
    };
  };
  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c "${pkgs.prometheus-shelly-exporter}/bin/shelly_exporter \
          -metrics-file ${cfg.metrics-file} \
          -listen-address ${cfg.listen-address}:${cfg.listen-port}"
      '';
    };
  };
}
