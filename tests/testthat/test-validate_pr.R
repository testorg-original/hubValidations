test_that("validate_pr works on valid PR", {
  skip_if_offline()

  temp_hub <- fs::path(tempdir(), "valid_sb_hub")
  gert::git_clone(
    url = "https://github.com/testorg-original/ci-testhub-simple",
    path = temp_hub,
    branch = "pr-valid"
  )

  checks <- validate_pr(
    hub_path = temp_hub,
    gh_repo = "testorg-original/ci-testhub-simple",
    pr_number = 1,
    skip_submit_window_check = TRUE
  )

  expect_snapshot(str(checks))
  expect_invisible(suppressMessages(check_for_errors(checks)))
  expect_message(check_for_errors(checks),
    regexp = "All validation checks have been successful."
  )
})

test_that("validate_pr works on invalid PR", {
  skip_if_offline()

  temp_hub <- fs::path(tempdir(), "invalid_sb_hub")
  gert::git_clone(
    url = "https://github.com/testorg-original/ci-testhub-simple",
    path = temp_hub,
    branch = "pr-missing-taskid"
  )

  invalid_checks <- validate_pr(
    hub_path = temp_hub,
    gh_repo = "testorg-original/ci-testhub-simple",
    pr_number = 4,
    skip_submit_window_check = TRUE
  )

  expect_snapshot(str(invalid_checks))

  expect_error(
    suppressMessages(check_for_errors(invalid_checks))
  )
})

test_that("validate_pr flags modifications and deletions in PR", {
  skip_if_offline()

  temp_hub <- fs::path(tempdir(), "mod_del_hub")
  gert::git_clone(
    url = "https://github.com/testorg-original/ci-testhub-simple",
    path = temp_hub,
    branch = "test-mod-del"
  )

  mod_checks_error <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "testorg-original/ci-testhub-simple",
      pr_number = 3,
      skip_submit_window_check = TRUE
    )
  )

  expect_snapshot(str(mod_checks_error))
  expect_error(
    suppressMessages(check_for_errors(mod_checks_error))
  )

  mod_checks_warn <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "testorg-original/ci-testhub-simple",
      pr_number = 3,
      skip_submit_window_check = TRUE,
      file_modification_check = "warn"
    )
  )
  expect_snapshot(str(mod_checks_warn))
  expect_error(
    suppressMessages(check_for_errors(mod_checks_warn))
  )

  mod_checks_message <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "testorg-original/ci-testhub-simple",
      pr_number = 3,
      skip_submit_window_check = TRUE,
      file_modification_check = "message"
    )
  )
  expect_snapshot(str(mod_checks_message))
  expect_true(
    suppressMessages(check_for_errors(mod_checks_message[1:5]))
  )


  mod_checks_none <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "testorg-original/ci-testhub-simple",
      pr_number = 3,
      skip_submit_window_check = TRUE,
      file_modification_check = "none"
    )
  )
  expect_snapshot(str(mod_checks_none))
  expect_true(
    suppressMessages(check_for_errors(mod_checks_none[1:5]))
  )

  mockery::stub(
    check_submission_time,
    "Sys.time",
    lubridate::as_datetime("2022-10-08 18:01:00 EEST"),
    2
  )
  mod_checks_in_window <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "testorg-original/ci-testhub-simple",
      pr_number = 3,
      skip_submit_window_check = TRUE,
      allow_submit_window_mods = TRUE
    )
  )
  expect_snapshot(str(mod_checks_in_window))
})



test_that("validate_pr handles errors in determining submission window & file renaming", {
  skip_if_offline()

  temp_hub <- fs::path(tempdir(), "mod_exec_error_hub")
  gert::git_clone(
    url = "https://github.com/testorg-original/ci-testhub-simple",
    path = temp_hub,
    branch = "test-exec-error-mod-delete"
  )

  mod_checks_exec_error <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "testorg-original/ci-testhub-simple",
      pr_number = 2,
      skip_submit_window_check = TRUE
    )
  )
  expect_snapshot(str(mod_checks_exec_error[1:5]))
  expect_error(
    suppressMessages(check_for_errors(mod_checks_exec_error))
  )
})
