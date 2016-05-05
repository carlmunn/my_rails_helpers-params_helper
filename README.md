# Incomplete documentation; moving target so the API has changed

# Params Helper (my_rails_helpers-params_helper)

Helper with dealing with params that are passed from the view/form to the controller then to the renderer/view to be displayed back to the user.

Defines defaults, aliases

Ignores default values

Handles inputs:
  * Select
  * Text for filter boxes

The toggler identifies if the parameters have been passed by checking if the parameters (first arg) is present. If the parameters haven't been passed this means the toggler is fresh.

### Description

Options are identified by a key to a hash that defines it's behavior
For a basic option:

When passing params to the controller params are passed to define the search options or order option.
These will have options which will over write the defaults. If the filter parameters aren't passed then the defaults are used.

Storing of selected options are also used. These come from the servers cache (memcache, redis, etc)
They are only used if there weren't any parameters passed. They are ignored when the filter has been because when the page loads the
form has their values set with the defaults which are over written with session saved.


#### Defining options with defaults

```
option_key => {val: <option>}
```

For a option that needs to have multi values with defaults set:

```
option_key => {val: [{option1: true}, {option1: false}, {option1: false}]}
```

You can have more than one default set, these would be used for multi select options. When using ```#get``` the result will be an Array with the selected options

```
obj.get(:option_key)
#=> #<MyRailsHelpers::ParamsHelper::OptionCollection>
```

Getting a single option will be

```
obj.get(:option_key)
#=> #<MyRailsHelpers::ParamsHelper::Option>
```

#### Alias

Aliases will convert the passed param into something else, this can help with avoiding complicated or hard to understand param options. Example: ```recent``` can be mapped to ```properties.id DESC``` which avoids exposing the DB structure.


## Controller

```ruby
@params_toggler = MyRailsHelpers::ParamsHelper::Toggler.new(params[:filter], {
  display:   {'sold' => true, 'withdrawn' => false, 'expired' => false},
  order_by:  :id,
  order_dir: 'DESC'
})
```

## View/Helper

When showing the user the selected buttons we'll want to include the default option which means that if there option isn't in the submitted parameters they'll be included any way unless specified.

Excluding the default is used for links, clicking on the link should flip the option from the previous.

Example: passed params are ```display = ['withdrawn']```

```
@params_toggler.get(:display)
# Returns options object
```

```
@params_toggler.get(:display, ignore: :defaults)
# Returns options object
```
