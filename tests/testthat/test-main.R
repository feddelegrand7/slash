testthat::test_that("slash class comprehensive tests", {
  s_strict <- slash$new(data = list(), strict = TRUE)
  testthat::expect_true(s_strict$is_strict())

  s_data <- slash$new(data = list(a = 1))
  testthat::expect_equal(s_data$get_all(), list(a = 1))

  sl <- slash$new()
  testthat::expect_equal(sl$get("nonexistent", default = "default"), "default")

  testthat::expect_error(
    sl$get("/invalid"),
    "Path cannot start or end with '/'"
  )

  testthat::expect_error(
    sl$get("invalid/"),
    "Path cannot start or end with '/'"
  )

  testthat::expect_error(
    sl$get("a//b"),
    "Path cannot contain empty keys"
  )

  testthat::expect_error(
    sl$get(123),
    "Path must be a single character string"
  )

  testthat::expect_error(
    sl$get(c("a", "b")),
    "Path must be a single character string"
  )

  s_strict <- slash$new(strict = TRUE)
  testthat::expect_error(
    s_strict$get("a/b"),
    "Element at path 'a/b' does not exist"
  )

  sl <- slash$new()
  sl$set("a/b/c", 123)
  testthat::expect_equal(sl$get("a/b/c"), 123)

  sl$set("a/b/c", 456)
  testthat::expect_equal(sl$get("a/b/c"), 456)

  sl$delete("a/b/c")
  testthat::expect_null(sl$get("a/b/c"))

  testthat::expect_silent(sl$delete("nonexistent"))

  sl$set("x/y", 1)
  sl$clear()
  testthat::expect_length(sl$get_all(), 0)

  sl$set("x/y", 1)
  testthat::expect_true(sl$exists("x"))
  testthat::expect_true(sl$exists("x/y"))
  testthat::expect_false(sl$exists("x/z"))

  sl$clear()
  sl$set("a/b", 1)
  sl$set("a/c", 2)
  sl$set("d/e/f", 3)
  testthat::expect_setequal(
    sort(sl$list_paths()),
    sort(c("a", "a/b", "a/c", "d", "d/e", "d/e/f"))
  )

  sl$clear()
  sl$set("a", NULL)
  resl <- sl$get_all()
  testthat::expect_null(resl$a)
  sl$set("a/b", NULL)
  resl <- sl$get_all()


  sl$clear()
  test_data <- list(a = list(b = 1, c = 2), d = list(e = list(f = 3)))
  sl$set("a/b", 1)
  sl$set("a/c", 2)
  sl$set("d/e/f", 3)
  testthat::expect_equal(sl$get_all(), test_data)

  testthat::expect_output(print(sl), "slash object")

  testthat::expect_output(sl$print_list("a"), "list\\(b = 1, c = 2\\)")

  sl$set_strict(TRUE)
  testthat::expect_true(sl$is_strict())

  sl$clear()
  sl$set("numbers/one", 1)
  sl$set("numbers/pi", 3.14159)
  testthat::expect_equal(sl$get("numbers/one"), 1)
  testthat::expect_equal(sl$get("numbers/pi"), 3.14159)

  sl$clear()
  sl$set("strings/hello", "world")
  testthat::expect_equal(sl$get("strings/hello"), "world")

  sl$clear()
  sl$set("logical/true", TRUE)
  sl$set("logical/false", FALSE)
  testthat::expect_true(sl$get("logical/true"))
  testthat::expect_false(sl$get("logical/false"))

  sl$clear()
  sl$set("vector/numbers", 1:5)
  testthat::expect_equal(sl$get("vector/numbers"), 1:5)

  sl$clear()
  df <- data.frame(x = 1:3, y = letters[1:3])
  sl$set("dataframe/simple", df)
  testthat::expect_equal(sl$get("dataframe/simple"), df)

  sl$clear()
  func <- function(x) x^2
  sl$set("function/square", func)
  testthat::expect_equal(sl$get("function/square")(3), 9)

  sl$clear()
  complex_data <- list(
    a = list(
      b = list(
        c = list(
          d = list(
            e = list(
              f = "deep"
            )
          )
        )
      )
    )
  )
  sl$set("a/b/c/d/e/f", "deep")
  testthat::expect_equal(sl$get_all(), complex_data)

  sl$clear()
  sl$set("first", 1)
  sl$set("second", 2)
  sl$set("third", 3)
  testthat::expect_length(sl$get_all(), 3)

  sl$clear()
  sl$set("mixed/numbers", 1:3)
  sl$set("mixed/string", "text")
  sl$set("mixed/logical", TRUE)
  testthat::expect_length(sl$get("mixed"), 3)

  sl$clear()
  sl$set("special/chars/with-dash", 1)
  sl$set("special/chars/with_underscore", 2)
  sl$set("special/chars/with.dot", 3)
  testthat::expect_equal(sl$get("special/chars/with-dash"), 1)
  testthat::expect_equal(sl$get("special/chars/with_underscore"), 2)
  testthat::expect_equal(sl$get("special/chars/with.dot"), 3)

  sl$clear()
  sl$set("a/b/c", list(x = 1, y = 2))
  sl$set("a/b/c", "simple")
  testthat::expect_equal(sl$get("a/b/c"), "simple")

  sl$clear()
  sl$set("a/b/c", "simple")
  sl$set("a/b/c", list(x = 1, y = 2))
  testthat::expect_equal(sl$get("a/b/c"), list(x = 1, y = 2))

  sl$clear()
  sl$set("a/b/c", 1)
  sl$set("a/b/d", 2)
  sl$delete("a/b")
  testthat::expect_error(sl$get("a/b/c"))
  testthat::expect_error(sl$get("a/b/d"))
  testthat::expect_false(sl$exists("a"))

  sl$clear()
  sl$set("a", 1)
  sl$set("b", 2)
  sl$delete("a")
  testthat::expect_error(sl$get("a"))
  testthat::expect_equal(sl$get("b"), 2)

  sl$clear()
  sl$set("a", 1)
  sl$delete("nonexistent")
  testthat::expect_equal(sl$get("a"), 1)

  s_strict <- slash$new(strict = TRUE)
  testthat::expect_error(
    s_strict$get("a/b"),
    "Element at path 'a/b' does not exist"
  )
  testthat::expect_equal(s_strict$get("a/b", default = 123), 123)

  sl$clear()
  sl$set("a/b", 1)
  testthat::expect_output(print(s, show_full = TRUE), "Full dictionary structure")

  testthat::expect_output(print(s), "Use \\$get\\(\\) or \\$get_all\\(\\)")

  sl$clear()
  testthat::expect_length(sl$list_paths(), 0)

  sl$clear()
  sl$set("a", 2)
  sl$set("b", 1)
  sl$set("c", 3)
  testthat::expect_equal(sl$list_paths(), c("a", "b", "c"))

  sl$clear()
  sl$set("a/b/c", 1)
  sl$set("a/b/d", 2)
  sl$set("a/e", 3)

  testthat::expect_equal(
    sl$list_paths(),
    c("a", "a/b", "a/b/c", "a/b/d", "a/e")
  )

  sl$clear()
  test_data <- list(a = 1, b = 2)
  sl$set("a", 1)
  sl$set("b", 2)
  testthat::expect_equal(sl$get(), test_data)

  testthat::expect_error(
    sl$set("", 1),
    "Please provide a valid path"
  )

  testthat::expect_error(
    sl$get(""),
    "Please provide a valid path"
  )

  testthat::expect_error(
    sl$exists(""),
    "Please provide a valid path"
  )

  testthat::expect_error(
    sl$delete(""),
    "Please provide a valid path"
  )

  sl$clear()
  long_path <- paste(letters, collapse = "/")
  sl$set(long_path, "value")
  testthat::expect_equal(sl$get(long_path), "value")

  sl$set("unicode/日本語", "value")
  testthat::expect_equal(sl$get("unicode/日本語"), "value")

  sl$set("path with spaces/key with spaces", 1)
  testthat::expect_equal(sl$get("path with spaces/key with spaces"), 1)

  sl$set("123/456", "numbers")
  testthat::expect_equal(sl$get("123/456"), "numbers")

  sl$set("a1/b2/c3/d4", "mixed")
  testthat::expect_equal(sl$get("a1/b2/c3/d4"), "mixed")

  sl$clear()
  sl$set("a", 1)
  sl$set("a", 2)
  testthat::expect_equal(sl$get("a"), 2)

  nested_list <- list(a = list(b = list(c = 1)))
  sl$clear()
  sl$set("x", nested_list)
  testthat::expect_equal(sl$get("x"), nested_list)

  sl$set("x/a/b/c", 2)
  testthat::expect_equal(sl$get("x/a/b/c"), 2)

  sl$delete("x/a/b/c")
  testthat::expect_error(sl$get("x/a/b/c"))

  sl$delete("x")
  testthat::expect_error(sl$get("x"))

  nested_data <- list(a = list(b = list(c = 1)))
  s_nested <- slash$new(data = nested_data)
  testthat::expect_equal(s_nested$get_all(), nested_data)

  vector_data <- list(a = 1:3, b = letters[1:3])
  s_vector <- slash$new(data = vector_data)
  testthat::expect_equal(s_vector$get_all(), vector_data)

  df_data <- list(df = data.frame(x = 1:3, y = letters[1:3]))
  s_df <- slash$new(data = df_data)
  testthat::expect_equal(s_df$get_all(), df_data)

  null_data <- list(a = NULL, b = list(c = NULL))
  s_null <- slash$new(data = null_data)
  testthat::expect_equal(s_null$get_all(), null_data)

  func_data <- list(f = function(x) x^2)
  s_func <- slash$new(data = func_data)
  testthat::expect_equal(s_func$get("f")(3), 9)

  mixed_data <- list(a = 1, b = "text", c = TRUE, d = list(e = 1:3))
  s_mixed <- slash$new(data = mixed_data)
  testthat::expect_equal(s_mixed$get_all(), mixed_data)

  sl$clear()
  sl$set("a/b/c/d/e", "deep")
  testthat::expect_equal(sl$get("a/b/c/d/e"), "deep")

  sl$clear()
  sl$set("x/y/z", 1)
  testthat::expect_true(sl$exists("x"))
  testthat::expect_true(sl$exists("x/y"))
  testthat::expect_true(sl$exists("x/y/z"))

  sl$set("x/y", 2)
  testthat::expect_equal(sl$get("x/y"), 2)
  testthat::expect_error(sl$get("x/y/z"))

  sl$clear()
  sl$set("a/b/c", 1)
  testthat::expect_true(sl$exists("a"))
  testthat::expect_true(sl$exists("a/b"))
  testthat::expect_true(sl$exists("a/b/c"))

  testthat::expect_false(sl$exists("x"))
  testthat::expect_false(sl$exists("a/x"))
  testthat::expect_false(sl$exists("a/b/x"))

  testthat::expect_equal(sl$get("x/y/z", default = "default"), "default")

  sl$clear()
  sl$set("a/b/c", 1)
  sl$set("a/b/d", 2)
  sl$set("a/e", 3)
  sl$set("f", 4)
  testthat::expect_setequal(
    sort(sl$list_paths()),
    sort(c("a", "a/b", "a/b/c", "a/b/d", "a/e", "f"))
  )

  sl$clear()
  testthat::expect_length(sl$list_paths(), 0)

  sl$set("a", 1)
  testthat::expect_equal(sl$list_paths(), "a")

  sl$clear()
  sl$set("a/b/c", 1)
  sl$set("a/b/d", 2)
  testthat::expect_setequal(
    sl$list_paths(),
    c("a", "a/b", "a/b/c", "a/b/d")
  )

  sl$clear()
  testthat::expect_length(sl$get_all(), 0)
  testthat::expect_length(sl$list_paths(), 0)

  sl$clear()
  testthat::expect_length(sl$get_all(), 0)

  test_data <- list(a = list(b = 1), c = 2)
  sl$set("a/b", 1)
  sl$set("c", 2)
  testthat::expect_equal(sl$get_all(), test_data)

  all_data <- sl$get_all()
  all_data$a <- "modified"
  testthat::expect_false(identical(sl$get_all(), all_data))

  s_strict <- slash$new(strict = TRUE)
  testthat::expect_output(print(s_strict), "strict")
  s_nonstrict <- slash$new(strict = FALSE)
  testthat::expect_output(print(s_nonstrict), "non-strict")

  sl$clear()
  sl$set("a/b", 1)
  testthat::expect_output(sl$print_list("a"), "list\\(b = 1\\)")

  testthat::expect_output(sl$print_list(), "list\\(a = list\\(b = 1\\)\\)")

  sl$set_strict(TRUE)
  testthat::expect_error(
    sl$get("nonexistent"),
    "Element at path 'nonexistent' does not exist"
  )

  sl$set_strict(FALSE)
  testthat::expect_null(sl$get("nonexistent"))
  sl$set_strict(TRUE)
  testthat::expect_error(sl$get("nonexistent"))

  sl$set_strict(TRUE)
  testthat::expect_true(sl$is_strict())
  sl$set_strict(FALSE)
  testthat::expect_false(sl$is_strict())

  s_empty <- slash$new(data = list())
  testthat::expect_length(s_empty$get_all(), 0)

  testthat::expect_error(
    slash$new(data = NULL),
    "type of list is expected for 'data', not NULL"
  )

  testthat::expect_error(
    slash$new(data = 123),
    "type of list is expected for 'data', not double"
  )

  testthat::expect_error(
    slash$new(strict = "true"),
    "'strict' parameter must be logical"
  )

  testthat::expect_error(
    slash$new(strict = NA),
    "strict' parameter cannot be NA"
  )

  testthat::expect_error(
    slash$new(strict = NULL),
    "'strict' parameter must be logical"
  )

  sl$clear()
  sl$set("a", 1)
  all_data <- sl$get_all()
  all_data$a <- 2
  testthat::expect_equal(sl$get("a"), 1)

  sl$clear()
  sl$set("a", 1)
  sl$set("b", 2)
  sl$set("a", 3)
  testthat::expect_equal(sl$get("b"), 2)

  sl$clear()
  sl$set("a", 1)
  sl$set("b", 2)
  sl$delete("a")
  testthat::expect_equal(sl$get("b"), 2)

  sl$set_strict(TRUE)
  sl$clear()
  testthat::expect_true(sl$is_strict())

  sl$clear()
  sl$set("a/b", 1)
  sl$set("a/c", 2)
  sl$set("d/e", 3)
  sl$delete("a/b")
  sl$set("d/f", 4)
  expected <- list(a = list(c = 2), d = list(e = 3, f = 4))
  testthat::expect_equal(sl$get_all(), expected)
})


testthat::test_that("Basic unnamed list operations", {
  sl <- slash$new(list("a", "b", "c"))

  testthat::expect_equal(sl$get("1"), "a")
  testthat::expect_equal(sl$get("2"), "b")
  testthat::expect_equal(sl$get("3"), "c")
  testthat::expect_equal(length(sl$get_all()), 3)
  testthat::expect_equal(sl$list_paths(), c("1", "2", "3"))

  testthat::expect_true(sl$exists("1"))
  testthat::expect_true(sl$exists("2"))
  testthat::expect_true(sl$exists("3"))
  testthat::expect_false(sl$exists("0"))
  testthat::expect_false(sl$exists("4"))

  sl$clear()

  testthat::expect_equal(sl$get_all(), list())
  testthat::expect_equal(sl$list_paths(), character(0))
  testthat::expect_false(sl$exists("1"))
  testthat::expect_null(sl$get("1"))
  testthat::expect_null(sl$get("1", NULL))
})

test_that("Nested unnamed list operations", {
  sl <- slash$new(list(list("a", "b"), list("c")))

  testthat::expect_equal(sl$get("1/1"), "a")
  testthat::expect_equal(sl$get("1/2"), "b")
  testthat::expect_equal(sl$get("2/1"), "c")
  testthat::expect_equal(
    sl$list_paths(),
    c("1", "1/1", "1/2", "2", "2/1")
  )

  testthat::expect_false(sl$exists("1/3"))

  sl$set("1/1", "aa")
  testthat::expect_equal(sl$get("1/1"), "aa")
  sl$set("3", list("d"))
  testthat::expect_equal(sl$get("3/1"), "d")
  sl$delete("1/2")
  testthat::expect_null(sl$get("1/2"))
  testthat::expect_equal(sl$list_paths(), c("1", "1/1", "2", "2/1", "3", "3/1"))

  sl$clear()
})

test_that("Edge cases with unnamed lists", {
  sl <- slash$new(list())
  sl$set("100", "x")
  testthat::expect_equal(length(sl$get_all()), 100)
  testthat::expect_equal(sl$get("100"), "x")
  testthat::expect_null(sl$get("99"))
  sl$delete("100")
  testthat::expect_equal(length(sl$get_all()), 99)

  sl$clear()
})

test_that("Mixed operations", {
  sl <- slash$new(list("a", list("b", "c"), "d"))

  testthat::expect_equal(sl$get("1"), "a")
  testthat::expect_equal(sl$get("2/1"), "b")
  testthat::expect_equal(sl$get("2/2"), "c")
  testthat::expect_equal(sl$get("3"), "d")
  testthat::expect_equal(sl$list_paths(), c("1", "2", "2/1", "2/2", "3"))

  sl$set("4", "e")
  testthat::expect_equal(sl$get("4"), "e")
  sl$set("2/3", "cc")
  testthat::expect_equal(sl$get("2/3"), "cc")
  sl$delete("2/3")
  testthat::expect_false(sl$exists("2/3"))
  testthat::expect_equal(sl$list_paths(), c("1", "2", "2/1", "2/2", "3", "4"))

  sl$set_strict(TRUE)
  testthat::expect_error(sl$get("5"))
  testthat::expect_error(sl$get("2/5"))
  sl$set_strict(FALSE)
  testthat::expect_null(sl$get("5"))
  testthat::expect_null(sl$get("2/5"))
  testthat::expect_equal(sl$get("2/5", "default"), "default")
})


test_data <- list(
  list(
    id = 1001,
    name = "John Doe",
    email = "john@example.com",
    roles = list("admin", "user"),
    active = TRUE
  ),
  list(
    id = 1002,
    name = "Jane Smith",
    email = "jane@example.com",
    roles = list("user"),
    active = FALSE
  ),
  list(
    id = 1003,
    name = "Bob Johnson",
    email = NULL,
    roles = list(),
    active = TRUE
  )
)

test_that("Basic array operations work", {
  sl <- slash$new(test_data)

  expect_equal(sl$get("1/name"), "John Doe")
  expect_equal(sl$get("2/email"), "jane@example.com")
  expect_true(sl$get("1/active"))
  expect_false(sl$get("2/active"))
  expect_null(sl$get("3/email"))

  expect_equal(length(sl$get_all()), 3)

  expected_paths <- c(
    "1", "1/id", "1/name", "1/email", "1/roles", "1/roles/1", "1/roles/2",
    "1/active", "2", "2/id", "2/name", "2/email", "2/roles", "2/roles/1",
    "2/active", "3", "3/id", "3/name", "3/email", "3/roles", "3/active"
  )

  expect_equal(
    sort(sl$list_paths()),
    sort(expected_paths)
  )

  expect_true(sl$exists("1/roles/1"))
  expect_false(sl$exists("1/roles/3"))
  expect_true(sl$exists("3/email"))
  expect_false(sl$exists("4"))
  expect_false(sl$exists("1/address"))
})

test_that("Modification operations work", {
  sl <- slash$new(test_data)


  sl$set("1/name", "Johnathan Doe")
  expect_equal(sl$get("1/name"), "Johnathan Doe")

  sl$set("2/roles/2", "manager")
  expect_equal(sl$get("2/roles/2"), "manager")

  sl$set("3/email", "bob@example.com")
  expect_equal(sl$get("3/email"), "bob@example.com")


  sl$set("4", list(id = 1004, name = "Alice Brown"))
  expect_equal(sl$get("4/name"), "Alice Brown")
  expect_equal(length(sl$get_all()), 4)

  sl$set("1/title", "CTO")
  expect_equal(sl$get("1/title"), "CTO")


  sl$delete("1/roles/2")
  expect_false(sl$exists("1/roles/2"))
  expect_equal(length(sl$get("1/roles")), 1)

  sl$delete("3/email")
  expect_null(sl$get("3/email"))

  sl$delete("2")
  expect_equal(length(sl$get_all()), 3)  # Indexes shift?

})

test_data <- list(
  list(
    id = 1001,
    name = "John Doe",
    email = "john@example.com",
    roles = list("admin", "user"),
    active = TRUE
  ),
  list(
    id = 1002,
    name = "Jane Smith",
    email = "jane@example.com",
    roles = list("user"),
    active = FALSE
  ),
  list(
    id = 1003,
    name = "Bob Johnson",
    email = NULL,  # Missing email
    roles = list("reader"),
    active = TRUE
  )
)

test_that("Edge cases with real data", {
  sl <- slash$new(test_data)


  expect_equal(sl$get("3/roles"), list("reader"))
  expect_true(sl$exists("3/roles"))
  sl$set("3/roles/1", "guest")
  expect_equal(sl$get("3/roles/1"), "guest")


  expect_null(sl$get("3/email"))
  expect_true(sl$exists("3/email"))


  sl$set_strict(TRUE)
  expect_error(sl$get("1/nonexistent"))
  expect_error(sl$get("5"))
  sl$set_strict(FALSE)
  expect_null(sl$get("1/nonexistent"))


  sl$set("1/roles/3", "superuser")
  expect_equal(sl$get("1/roles/3"), "superuser")

  sl$delete("1/roles")
  expect_false(sl$exists("1/roles"))

  sl$set("1/roles", list("admin"))
  expect_equal(sl$get("1/roles/1"), "admin")

  sl$clear()
  expect_equal(sl$get_all(), list())
  expect_equal(sl$list_paths(), character(0))
})

test_that("filtering paths works as expected", {

  sl <- slash$new()

  sl$set("a/b", 10)
  sl$set("a/b/c", 20)
  sl$set("a/z", 50)

  exp_path <- c("a", "a/b", "a/b/c", "a/z")

  expect_equal(sl$filter_paths("a"), exp_path)
  expect_equal(sl$list_paths(), sl$filter_paths("a"))
  expect_length(sl$filter_paths("z"), 1)
  expect_equal(sl$filter_paths("z"), "a/z")
  expect_length(sl$filter_paths("b$"), 1)
  expect_equal(sl$filter_paths("b$"), "a/b")

})

