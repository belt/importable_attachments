Feature: administrator uploads generic file
  As an administrator
  I want to upload a generic file
  So that I can confirm the uploading machina is working

  @javascript
  Scenario: upload file
    Given I am on the new attachment page
    And I upload the spec file "mostly_empty.csv" as "attachment_io_stream"
    Then I should see "Successfully created attachment."

