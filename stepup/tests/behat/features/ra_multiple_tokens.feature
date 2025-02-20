Feature: A RAA (jane a ra) has two loa 3 tokens which makes her a valid RA candidate
  In order to verify you will lose ra credibility
  As an Admin
  I verify removing all tokes of jane makes her lose her RA roles

  Scenario: Provision a institution and a user to promote later on by an authorized institution
    Given I have the payload
        """
        {
            "institution-a.example.com": {
                "use_ra_locations": true,
                "show_raa_contact_information": true,
                "verify_email": true,
                "allowed_second_factors": [],
                "number_of_tokens_per_identity": 2,
                "select_raa": [
                    "institution-a.example.com"
                ]
            },
            "institution-b.example.com": {
                "use_ra_locations": true,
                "show_raa_contact_information": true,
                "verify_email": true,
                "allowed_second_factors": [],
                "number_of_tokens_per_identity": 2,
                "select_raa": [
                    "institution-a.example.com"
                ]
            },
            "institution-d.example.com": {
                "use_ra_locations": false,
                "show_raa_contact_information": false,
                "verify_email": false,
                "allowed_second_factors": ["sms"],
                "number_of_tokens_per_identity": 1,
                "select_raa": [
                    "institution-a.example.com"
                ]
            }
        }
        """
    And I authenticate to the Middleware API
    And I request "POST /management/institution-configuration"
    And a user "jane-a-ra" identified by "urn:collab:person:institution-a.example.com:jane-a-ra" from institution "institution-a.example.com" with UUID "00000000-0000-4000-8000-000000000001"
    And the user "urn:collab:person:institution-a.example.com:jane-a-ra" has a vetted "yubikey" with identifier "00000004"
    And the user "urn:collab:person:institution-a.example.com:jane-a-ra" has a vetted "demo-gssp" with identifier "gssp-identifier123"
    And the user "urn:collab:person:institution-a.example.com:jane-a-ra" has the role "raa" for institution "institution-a.example.com"
    And the user "urn:collab:person:institution-a.example.com:jane-a-ra" has the role "raa" for institution "institution-b.example.com"
    And the user "urn:collab:person:institution-a.example.com:jane-a-ra" has the role "raa" for institution "institution-d.example.com"

  Scenario: SRAA user checks if "Jane Toppan" is not a candidate for institutions
    Given I am logged in into the ra portal as "admin" with a "yubikey" token
    When I visit the RA promotion page
    Then I should see the following candidates:
      | name                                | institution               |
      | jane-a-ra                           | institution-a.example.com |
      | Admin                               | dev.openconext.local      |

  Scenario: SRAA user checks if "jane-a-ra" is a candidate for institutions if relieved from the RAA role
    Given I am logged in into the ra portal as "admin" with a "yubikey" token
    When I visit the RA Management page
     And I relieve "jane-a-ra" from "institution-a.example.com" of his "RAA" role
    Then I visit the RA promotion page
    And I should see the following candidates:
      | name                                | institution               |
      | jane-a-ra                           | institution-a.example.com |
      | Admin                               | dev.openconext.local      |

  Scenario: Sraa revokes only one vetted token from "jane-a-ra" and that shouldn't remove her as candidate
    Given I am logged in into the ra portal as "admin" with a "yubikey" token
    When I visit the Tokens page
      And I remove token with identifier "00000004" from user "jane-a-ra"
    Then I visit the RA promotion page
      And I should see the following candidates:
        | name                                | institution               |
        | jane-a-ra                           | institution-a.example.com |
        | Admin                               | dev.openconext.local      |

  Scenario: Sraa revokes the last vetted token from "Jane Toppan" and that must remove her as candidate
    Given I am logged in into the ra portal as "admin" with a "yubikey" token
    When I visit the Tokens page
      And I remove token with identifier "gssp-identifier123" from user "jane-a-ra"
    Then I visit the RA promotion page
      And I should see the following candidates:
        | name                                | institution               |
        | Admin                               | dev.openconext.local      |
