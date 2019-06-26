# Required command line pillar data:
#   tgt_hst: Targeted Host/role
#   tgt_pod: Targeted Pod/group
#   tgt_loc: Targeted Location
{% import "orch/aws/jinja2.sls" as aws with context -%}
{% set HST = pillar.tgt_hst -%}
{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}


### CloudFront


# INCOMPLETE
# 1. https://github.com/saltstack/salt/issues/50073
# 2. boto_cloudfront update_distribution requires optional config data
# 3. hardcoded mid-dev values below

{% set ident = [HST, POD, "cloudfront"] -%}
{% set name = ident|join("_") -%}
{{ sls }} {{ name }}:
  boto_cloudfront.present:
    - region: {{ LOC }}
    - name: {{ name }}
    - config:
        Aliases:
          Quantity: 1
          Items:
            - chapter.creativecommons.org
        CallerReference: v0001
        Comment: SaltStack {{ name }}
        DefaultCacheBehavior:
          ForwardedValues:
            Cookies:
              Forward: all
            QueryString: True
          MinTTL: 0
          TargetOriginId: chapters__prod__us-east-2
          TrustedSigners:
            Enabled: False
            Quantity: 0
          ViewerProtocolPolicy: allow-all
        Enabled: True
        HttpVersion: http2
        IsIPV6Enabled: True
        Logging:
          # need to configure logging to support updates.
        Origins:
          Quantity: 1
          Items:
            # Must be a Public IP
            - DomainName: ip-10-22-10-14.us-east-2.compute.internal
              Id: chapters__prod__us-east-2
              CustomOriginConfig:
                HTTPPort: 80
                HTTPSPort: 443
                OriginProtocolPolicy: match-viewer
                OriginSslProtocols:
                  Quantity: 1
                  Items:
                    - TLSv1.2
        PriceClass: PriceClass_All
    {{ aws.tags(ident) }}
