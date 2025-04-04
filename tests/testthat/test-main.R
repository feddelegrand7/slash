testthat::test_that("slash class comprehensive tests", {
  s_strict <- slash$new(data = list(), strict = TRUE)
  testthat::expect_true(s_strict$is_strict())

  s_data <- slash$new(data = list(a = 1))
  testthat::expect_equal(s_data$get_all(), list(a = 1))

  s <- slash$new()
  testthat::expect_equal(s$get("nonexistent", default = "default"), "default")

  testthat::expect_error(
    s$get("/invalid"),
    "Path cannot start or end with '/'"
  )

  testthat::expect_error(
    s$get("invalid/"),
    "Path cannot start or end with '/'"
  )

  testthat::expect_error(
    s$get("a//b"),
    "Path cannot contain empty keys"
  )

  testthat::expect_error(
    s$get(123),
    "Path must be a single character string"
  )

  testthat::expect_error(
    s$get(c("a", "b")),
    "Path must be a single character string"
  )

  s_strict <- slash$new(strict = TRUE)
  testthat::expect_error(
    s_strict$get("a/b"),
    "Element at path 'a/b' does not exist"
  )

  s <- slash$new()
  s$set("a/b/c", 123)
  testthat::expect_equal(s$get("a/b/c"), 123)

  s$set("a/b/c", 456)
  testthat::expect_equal(s$get("a/b/c"), 456)

  s$delete("a/b/c")
  testthat::expect_null(s$get("a/b/c"))

  testthat::expect_silent(s$delete("nonexistent"))

  s$set("x/y", 1)
  s$clear()
  testthat::expect_length(s$get_all(), 0)

  s$set("x/y", 1)
  testthat::expect_true(s$exists("x"))
  testthat::expect_true(s$exists("x/y"))
  testthat::expect_false(s$exists("x/z"))

  s$clear()
  s$set("a/b", 1)
  s$set("a/c", 2)
  s$set("d/e/f", 3)
  testthat::expect_setequal(
    sort(s$list_paths()),
    sort(c("a", "a/b", "a/c", "d", "d/e", "d/e/f"))
  )

  s$clear()
  s$set("a", NULL)
  res <- s$get_all()
  testthat::expect_null(res$a)
  s$set("a/b", NULL)
  res <- s$get_all()


  s$clear()
  test_data <- list(a = list(b = 1, c = 2), d = list(e = list(f = 3)))
  s$set("a/b", 1)
  s$set("a/c", 2)
  s$set("d/e/f", 3)
  testthat::expect_equal(s$get_all(), test_data)

  testthat::expect_output(print(s), "slash object")

  testthat::expect_output(s$print_list("a"), "list\\(b = 1, c = 2\\)")

  s$set_strict(TRUE)
  testthat::expect_true(s$is_strict())

  s$clear()
  s$set("numbers/one", 1)
  s$set("numbers/pi", 3.14159)
  testthat::expect_equal(s$get("numbers/one"), 1)
  testthat::expect_equal(s$get("numbers/pi"), 3.14159)

  s$clear()
  s$set("strings/hello", "world")
  testthat::expect_equal(s$get("strings/hello"), "world")

  s$clear()
  s$set("logical/true", TRUE)
  s$set("logical/false", FALSE)
  testthat::expect_true(s$get("logical/true"))
  testthat::expect_false(s$get("logical/false"))

  s$clear()
  s$set("vector/numbers", 1:5)
  testthat::expect_equal(s$get("vector/numbers"), 1:5)

  s$clear()
  df <- data.frame(x = 1:3, y = letters[1:3])
  s$set("dataframe/simple", df)
  testthat::expect_equal(s$get("dataframe/simple"), df)

  s$clear()
  func <- function(x) x^2
  s$set("function/square", func)
  testthat::expect_equal(s$get("function/square")(3), 9)

  s$clear()
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
  s$set("a/b/c/d/e/f", "deep")
  testthat::expect_equal(s$get_all(), complex_data)

  s$clear()
  s$set("first", 1)
  s$set("second", 2)
  s$set("third", 3)
  testthat::expect_length(s$get_all(), 3)

  s$clear()
  s$set("mixed/numbers", 1:3)
  s$set("mixed/string", "text")
  s$set("mixed/logical", TRUE)
  testthat::expect_length(s$get("mixed"), 3)

  s$clear()
  s$set("special/chars/with-dash", 1)
  s$set("special/chars/with_underscore", 2)
  s$set("special/chars/with.dot", 3)
  testthat::expect_equal(s$get("special/chars/with-dash"), 1)
  testthat::expect_equal(s$get("special/chars/with_underscore"), 2)
  testthat::expect_equal(s$get("special/chars/with.dot"), 3)

  s$clear()
  s$set("a/b/c", list(x = 1, y = 2))
  s$set("a/b/c", "simple")
  testthat::expect_equal(s$get("a/b/c"), "simple")

  s$clear()
  s$set("a/b/c", "simple")
  s$set("a/b/c", list(x = 1, y = 2))
  testthat::expect_equal(s$get("a/b/c"), list(x = 1, y = 2))

  s$clear()
  s$set("a/b/c", 1)
  s$set("a/b/d", 2)
  s$delete("a/b")
  testthat::expect_error(s$get("a/b/c"))
  testthat::expect_error(s$get("a/b/d"))
  testthat::expect_false(s$exists("a"))

  s$clear()
  s$set("a", 1)
  s$set("b", 2)
  s$delete("a")
  testthat::expect_error(s$get("a"))
  testthat::expect_equal(s$get("b"), 2)

  s$clear()
  s$set("a", 1)
  s$delete("nonexistent")
  testthat::expect_equal(s$get("a"), 1)

  s_strict <- slash$new(strict = TRUE)
  testthat::expect_error(
    s_strict$get("a/b"),
    "Element at path 'a/b' does not exist"
  )
  testthat::expect_equal(s_strict$get("a/b", default = 123), 123)

  s$clear()
  s$set("a/b", 1)
  testthat::expect_output(print(s, show_full = TRUE), "Full dictionary structure")

  testthat::expect_output(print(s), "Use \\$get\\(\\) or \\$get_all\\(\\)")

  s$clear()
  testthat::expect_length(s$list_paths(), 0)

  s$clear()
  s$set("a", 2)
  s$set("b", 1)
  s$set("c", 3)
  testthat::expect_equal(s$list_paths(), c("a", "b", "c"))

  s$clear()
  s$set("a/b/c", 1)
  s$set("a/b/d", 2)
  s$set("a/e", 3)

  testthat::expect_equal(
    s$list_paths(),
    c("a", "a/b", "a/b/c", "a/b/d", "a/e")
  )

  s$clear()
  test_data <- list(a = 1, b = 2)
  s$set("a", 1)
  s$set("b", 2)
  testthat::expect_equal(s$get(), test_data)

  testthat::expect_error(
    s$set("", 1),
    "Please provide a valid path"
  )

  testthat::expect_error(
    s$get(""),
    "Please provide a valid path"
  )

  testthat::expect_error(
    s$exists(""),
    "Please provide a valid path"
  )

  testthat::expect_error(
    s$delete(""),
    "Please provide a valid path"
  )

  s$clear()
  long_path <- paste(letters, collapse = "/")
  s$set(long_path, "value")
  testthat::expect_equal(s$get(long_path), "value")

  s$set("unicode/日本語", "value")
  testthat::expect_equal(s$get("unicode/日本語"), "value")

  s$set("path with spaces/key with spaces", 1)
  testthat::expect_equal(s$get("path with spaces/key with spaces"), 1)

  s$set("123/456", "numbers")
  testthat::expect_equal(s$get("123/456"), "numbers")

  s$set("a1/b2/c3/d4", "mixed")
  testthat::expect_equal(s$get("a1/b2/c3/d4"), "mixed")

  s$clear()
  s$set("a", 1)
  s$set("a", 2)
  testthat::expect_equal(s$get("a"), 2)

  nested_list <- list(a = list(b = list(c = 1)))
  s$clear()
  s$set("x", nested_list)
  testthat::expect_equal(s$get("x"), nested_list)

  s$set("x/a/b/c", 2)
  testthat::expect_equal(s$get("x/a/b/c"), 2)

  s$delete("x/a/b/c")
  testthat::expect_error(s$get("x/a/b/c"))

  s$delete("x")
  testthat::expect_error(s$get("x"))

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

  s$clear()
  s$set("a/b/c/d/e", "deep")
  testthat::expect_equal(s$get("a/b/c/d/e"), "deep")

  s$clear()
  s$set("x/y/z", 1)
  testthat::expect_true(s$exists("x"))
  testthat::expect_true(s$exists("x/y"))
  testthat::expect_true(s$exists("x/y/z"))

  s$set("x/y", 2)
  testthat::expect_equal(s$get("x/y"), 2)
  testthat::expect_error(s$get("x/y/z"))

  s$clear()
  s$set("a/b/c", 1)
  testthat::expect_true(s$exists("a"))
  testthat::expect_true(s$exists("a/b"))
  testthat::expect_true(s$exists("a/b/c"))

  testthat::expect_false(s$exists("x"))
  testthat::expect_false(s$exists("a/x"))
  testthat::expect_false(s$exists("a/b/x"))

  testthat::expect_equal(s$get("x/y/z", default = "default"), "default")

  s$clear()
  s$set("a/b/c", 1)
  s$set("a/b/d", 2)
  s$set("a/e", 3)
  s$set("f", 4)
  testthat::expect_setequal(
    sort(s$list_paths()),
    sort(c("a", "a/b", "a/b/c", "a/b/d", "a/e", "f"))
  )

  s$clear()
  testthat::expect_length(s$list_paths(), 0)

  s$set("a", 1)
  testthat::expect_equal(s$list_paths(), "a")

  s$clear()
  s$set("a/b/c", 1)
  s$set("a/b/d", 2)
  testthat::expect_setequal(
    s$list_paths(),
    c("a", "a/b", "a/b/c", "a/b/d")
  )

  s$clear()
  testthat::expect_length(s$get_all(), 0)
  testthat::expect_length(s$list_paths(), 0)

  s$clear()
  testthat::expect_length(s$get_all(), 0)

  test_data <- list(a = list(b = 1), c = 2)
  s$set("a/b", 1)
  s$set("c", 2)
  testthat::expect_equal(s$get_all(), test_data)

  all_data <- s$get_all()
  all_data$a <- "modified"
  testthat::expect_false(identical(s$get_all(), all_data))

  s_strict <- slash$new(strict = TRUE)
  testthat::expect_output(print(s_strict), "strict")
  s_nonstrict <- slash$new(strict = FALSE)
  testthat::expect_output(print(s_nonstrict), "non-strict")

  s$clear()
  s$set("a/b", 1)
  testthat::expect_output(s$print_list("a"), "list\\(b = 1\\)")

  testthat::expect_output(s$print_list(), "list\\(a = list\\(b = 1\\)\\)")

  s$set_strict(TRUE)
  testthat::expect_error(
    s$get("nonexistent"),
    "Element at path 'nonexistent' does not exist"
  )

  s$set_strict(FALSE)
  testthat::expect_null(s$get("nonexistent"))
  s$set_strict(TRUE)
  testthat::expect_error(s$get("nonexistent"))

  s$set_strict(TRUE)
  testthat::expect_true(s$is_strict())
  s$set_strict(FALSE)
  testthat::expect_false(s$is_strict())

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

  s$clear()
  s$set("a", 1)
  all_data <- s$get_all()
  all_data$a <- 2
  testthat::expect_equal(s$get("a"), 1)

  s$clear()
  s$set("a", 1)
  s$set("b", 2)
  s$set("a", 3)
  testthat::expect_equal(s$get("b"), 2)

  s$clear()
  s$set("a", 1)
  s$set("b", 2)
  s$delete("a")
  testthat::expect_equal(s$get("b"), 2)

  s$set_strict(TRUE)
  s$clear()
  testthat::expect_true(s$is_strict())

  s$clear()
  s$set("a/b", 1)
  s$set("a/c", 2)
  s$set("d/e", 3)
  s$delete("a/b")
  s$set("d/f", 4)
  expected <- list(a = list(c = 2), d = list(e = 3, f = 4))
  testthat::expect_equal(s$get_all(), expected)
})


testthat::test_that("Basic unnamed list operations", {
  s <- slash$new(list("a", "b", "c"))

  testthat::expect_equal(s$get("1"), "a")
  testthat::expect_equal(s$get("2"), "b")
  testthat::expect_equal(s$get("3"), "c")
  testthat::expect_equal(length(s$get_all()), 3)
  testthat::expect_equal(s$list_paths(), c("1", "2", "3"))

  testthat::expect_true(s$exists("1"))
  testthat::expect_true(s$exists("2"))
  testthat::expect_true(s$exists("3"))
  testthat::expect_false(s$exists("0"))
  testthat::expect_false(s$exists("4"))

  s$clear()

  testthat::expect_equal(s$get_all(), list())
  testthat::expect_equal(s$list_paths(), character(0))
  testthat::expect_false(s$exists("1"))
  testthat::expect_null(s$get("1"))
  testthat::expect_null(s$get("1", NULL))
})

test_that("Nested unnamed list operations", {
  s <- slash$new(list(list("a", "b"), list("c")))

  testthat::expect_equal(s$get("1/1"), "a")
  testthat::expect_equal(s$get("1/2"), "b")
  testthat::expect_equal(s$get("2/1"), "c")
  testthat::expect_equal(
    s$list_paths(),
    c("1", "1/1", "1/2", "2", "2/1")
  )

  testthat::expect_false(s$exists("1/3"))

  s$set("1/1", "aa")
  testthat::expect_equal(s$get("1/1"), "aa")
  s$set("3", list("d"))
  testthat::expect_equal(s$get("3/1"), "d")
  s$delete("1/2")
  testthat::expect_null(s$get("1/2"))
  testthat::expect_equal(s$list_paths(), c("1", "1/1", "2", "2/1", "3", "3/1"))

  s$clear()
})

test_that("Edge cases with unnamed lists", {
  s <- slash$new(list())
  s$set("100", "x")
  testthat::expect_equal(length(s$get_all()), 100)
  testthat::expect_equal(s$get("100"), "x")
  testthat::expect_null(s$get("99"))
  s$delete("100")
  testthat::expect_equal(length(s$get_all()), 99)

  s$clear()
})

test_that("Mixed operations", {
  s <- slash$new(list("a", list("b", "c"), "d"))

  testthat::expect_equal(s$get("1"), "a")
  testthat::expect_equal(s$get("2/1"), "b")
  testthat::expect_equal(s$get("2/2"), "c")
  testthat::expect_equal(s$get("3"), "d")
  testthat::expect_equal(s$list_paths(), c("1", "2", "2/1", "2/2", "3"))

  s$set("4", "e")
  testthat::expect_equal(s$get("4"), "e")
  s$set("2/3", "cc")
  testthat::expect_equal(s$get("2/3"), "cc")
  s$delete("2/3")
  testthat::expect_false(s$exists("2/3"))
  testthat::expect_equal(s$list_paths(), c("1", "2", "2/1", "2/2", "3", "4"))

  s$set_strict(TRUE)
  testthat::expect_error(s$get("5"))
  testthat::expect_error(s$get("2/5"))
  s$set_strict(FALSE)
  testthat::expect_null(s$get("5"))
  testthat::expect_null(s$get("2/5"))
  testthat::expect_equal(s$get("2/5", "default"), "default")
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
  s <- slash$new(test_data)

  expect_equal(s$get("1/name"), "John Doe")
  expect_equal(s$get("2/email"), "jane@example.com")
  expect_true(s$get("1/active"))
  expect_false(s$get("2/active"))
  expect_null(s$get("3/email"))

  expect_equal(length(s$get_all()), 3)

  expected_paths <- c(
    "1", "1/id", "1/name", "1/email", "1/roles", "1/roles/1", "1/roles/2",
    "1/active", "2", "2/id", "2/name", "2/email", "2/roles", "2/roles/1",
    "2/active", "3", "3/id", "3/name", "3/email", "3/roles", "3/active"
  )

  expect_equal(
    sort(s$list_paths()),
    sort(expected_paths)
  )

  expect_true(s$exists("1/roles/1"))
  expect_false(s$exists("1/roles/3"))
  expect_true(s$exists("3/email"))
  expect_false(s$exists("4"))
  expect_false(s$exists("1/address"))
})

test_that("Modification operations work", {
  s <- slash$new(test_data)


  s$set("1/name", "Johnathan Doe")
  expect_equal(s$get("1/name"), "Johnathan Doe")

  s$set("2/roles/2", "manager")
  expect_equal(s$get("2/roles/2"), "manager")

  s$set("3/email", "bob@example.com")
  expect_equal(s$get("3/email"), "bob@example.com")


  s$set("4", list(id = 1004, name = "Alice Brown"))
  expect_equal(s$get("4/name"), "Alice Brown")
  expect_equal(length(s$get_all()), 4)

  s$set("1/title", "CTO")
  expect_equal(s$get("1/title"), "CTO")


  s$delete("1/roles/2")
  expect_false(s$exists("1/roles/2"))
  expect_equal(length(s$get("1/roles")), 1)

  s$delete("3/email")
  expect_null(s$get("3/email"))

  s$delete("2")
  expect_equal(length(s$get_all()), 3)  # Indexes shift?

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
  s <- slash$new(test_data)


  expect_equal(s$get("3/roles"), list("reader"))
  expect_true(s$exists("3/roles"))
  s$set("3/roles/1", "guest")
  expect_equal(s$get("3/roles/1"), "guest")


  expect_null(s$get("3/email"))
  expect_true(s$exists("3/email"))


  s$set_strict(TRUE)
  expect_error(s$get("1/nonexistent"))
  expect_error(s$get("5"))
  s$set_strict(FALSE)
  expect_null(s$get("1/nonexistent"))


  s$set("1/roles/3", "superuser")
  expect_equal(s$get("1/roles/3"), "superuser")

  s$delete("1/roles")
  expect_false(s$exists("1/roles"))

  s$set("1/roles", list("admin"))
  expect_equal(s$get("1/roles/1"), "admin")

  s$clear()
  expect_equal(s$get_all(), list())
  expect_equal(s$list_paths(), character(0))
})

