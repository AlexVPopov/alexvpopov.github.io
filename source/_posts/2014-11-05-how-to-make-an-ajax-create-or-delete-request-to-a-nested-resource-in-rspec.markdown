---
layout: post
title: "How to make an AJAX create or delete request to a nested resource in RSpec"
date: 2014-11-05 17:10
comments: true
categories: Rails, Testing
keywords: rspec, request, create, destroy, post, delete, nested resources, ajax
description: A short tutorial for describing how to construct an ajax create or delete request in RSpec.
---

Suppose you have a nested resource:

```ruby
resources :photos do
  resources :likes, only: [:create, :destroy]
end
```

Let's say that in your view clicking on a like button of a photo triggers an
AJAX request to the `LikesController`. <!-- more --> The request either `create`s a like if
the user hasn't likes the photo yet or `destroy`s it. The urls must look like
this:

Verb | Action | Path
---- | ------ | ----
`post` | `create` | `/photos/:photo_id/likes`
`delete` | `destroy` | `/photos/:photo_id/like/:id`


In that case you need to construct a request in your specs which has the
following characteristics:
* be an AJAX request;
* be a `POST` or `DELETE` request;
* contain the photo id;
* contain the like id in the case of `destroy`.

So the `create` requests will roughly look like that:

```ruby
xhr :post, :create, photo_id: photo.id
```
where
* `xhr` tells `RSpec` to make an AJAX request;
* `:post` is the request verb;
* `:create` is the controller action;
* `photo_id` is the id of the photo the like must be created on. This assumes
you have fabricated a photo and assigned it to the instance variable `photo`.

The `destroy` request will be similar, but you also have to supply the like id:

```ruby
xhr :delete, :destroy, photo_id: photo.id, id: like.id
```
It again assumes that you have fabricated a like and assigned it to `like`.
