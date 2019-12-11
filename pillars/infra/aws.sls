infra:
  aws:
    tags:
      # Default
      default:
        cc:environment: DATA-INCOMPLETE
        cc:product: DATA-INCOMPLETE
        cc:purpose: DATA-INCOMPLETE
        cc:team: internal-tech
      # Specific (please maintain order)
      bastion-us-east-2__core:
        cc:environment: production
        cc:product: infrastructure
        cc:purpose: bastion
        cc:team: internal-tech
      biztool__prod:
        cc:environment: production
        cc:product: business-toolkit
        cc:purpose: wordpress-hosting
        cc:team: internal-tech
      chapters__prod:
        cc:environment: production
        cc:product: chapter-sites
        cc:purpose: wordpress-hosting
        cc:team: internal-tech
      chapters__stage:
        cc:environment: staging
        cc:product: chapter-sites
        cc:purpose: wordpress-hosting
        cc:team: internal-tech
      core__secgroup:
        cc:environment: production
        cc:product: infrastructure
        cc:purpose: security-group
        cc:team: internal-tech
      discourse__dev:
        cc:environment: development
        cc:product: cc-create
        cc:purpose: discourse-hosting
        cc:team: internal-tech
      dispatch__stage:
        cc:environment: staging
        cc:product: primary-website
        cc:purpose: dispatch-urls
        cc:team: internal-tech
      openglam__prod:
        cc:environment: production
        cc:product: openglam
        cc:purpose: wordpress-hosting
        cc:team: internal-tech
      podcast__prod:
        cc:environment: production
        cc:product: podcast-plays-well-with-others
        cc:purpose: wordpress-hosting
        cc:team: internal-tech
      redirects__core:
        cc:environment: production
        cc:product: web-redirects
        cc:purpose: web-redirects
        cc:team: internal-tech
      salt-prime__core:
        cc:environment: production
        cc:product: infrastructure
        cc:purpose: saltstack
        cc:team: internal-tech
      sotc__prod:
        cc:environment: production
        cc:product: state-of-the-commons
        cc:purpose: wordpress-hosting
        cc:team: internal-tech
      summit__prod:
        cc:environment: production
        cc:product: global-summit
        cc:purpose: wordpress-hosting
        cc:team: internal-tech
      wikijs__core:
        cc:environment: production
        cc:product: wiki-internal
        cc:purpose: wikijs-hosting
        cc:team: internal-tech
