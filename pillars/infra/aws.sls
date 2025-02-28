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
      ccengine__prod:
        cc:environment: production
        cc:product: primary-website
        cc:purpose: ccengine
        cc:team: internal-tech
      index__prod:
        cc:environment: production
        cc:product: primary-website
        cc:purpose: wordpress-hosting
        cc:team: internal-tech
      index__stage:
        cc:environment: staging
        cc:product: primary-website
        cc:purpose: wordpress-hosting
        cc:team: internal-tech
      ccstatic__prod:
        cc:environment: production
        cc:product: ccstatic
        cc:purpose: static-hosting
        cc:team: internal-tech
      cert__prod:
        cc:environment: production
        cc:product: certificate
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
      licbuttons__prod:
        cc:environment: production
        cc:product: licensebuttons
        cc:purpose: static-hosting
        cc:team: internal-tech
      misc__prod:
        cc:environment: production
        cc:product: primary-website
        cc:purpose: static-hosting
        cc:team: internal-tech
      opencovid__prod:
        cc:environment: production
        cc:product: open-covid-pledge
        cc:purpose: wordpress-hosting
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
