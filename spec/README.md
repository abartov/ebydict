# EbyDict RSpec Test Suite

## Overview

This directory contains the comprehensive RSpec test suite for the EbyDict application, implementing behavior-driven development (BDD) testing for the Hebrew dictionary transcription platform.

## Setup

### Installation

The test suite has been set up with the following gems:

**Development & Test:**
- `rspec-rails` (~> 6.0) - Rails integration for RSpec
- `factory_bot_rails` (~> 6.2) - Test data factories
- `faker` (~> 3.0) - Realistic fake data generation

**Test Only:**
- `shoulda-matchers` (~> 5.3) - Simplified model/controller testing
- `database_cleaner-active_record` (~> 2.1) - Database state management
- `simplecov` - Code coverage reporting (target: 80%)
- `vcr` (~> 6.1) - HTTP interaction recording for OAuth
- `webmock` (~> 3.18) - HTTP request stubbing
- `rails-controller-testing` (~> 1.0) - Controller test helpers
- `timecop` (~> 0.9) - Time travel for date/time testing
- `capybara` (~> 3.39) - System/integration testing
- `selenium-webdriver` - Browser automation for system tests

### Database Setup

The test suite uses SQLite for speed and simplicity. The production application uses MySQL, so we've created a compatibility layer:

```bash
# Set up the test database (run once or when schema changes)
RAILS_ENV=test bundle exec rake test_db:setup
```

This creates a SQLite-compatible version of the schema without MySQL-specific collations.

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/eby_user_spec.rb

# Run tests by type
bundle exec rspec spec/models
bundle exec rspec spec/controllers
bundle exec rspec spec/requests
bundle exec rspec spec/lib

# Run with documentation format
bundle exec rspec --format documentation

# Run tests in random order (detect order dependencies)
bundle exec rspec --order random

# Run only failed tests from last run
bundle exec rspec --only-failures
```

### Coverage Reports

After running tests, open the coverage report:

```bash
open coverage/index.html
```

**Current Coverage Goal:** 80% overall
- Models: 90%+
- Controllers: 75%+
- Libraries: 90%+

## Directory Structure

```
spec/
├── factories/                    # FactoryBot factory definitions
│   ├── eby_users.rb             # User factory with role/language traits
│   ├── eby_defs.rb              # Definition factory with status traits
│   ├── eby_scan_images.rb       # Scan image factory
│   ├── eby_column_images.rb     # Column image factory
│   ├── eby_def_part_images.rb   # Definition part image factory
│   ├── eby_def_events.rb        # Event/audit factory
│   ├── eby_aliases.rb           # Alias factory
│   └── eby_markers.rb           # Marker factory
├── fixtures/                     # Test fixtures
│   └── images/                  # Generated test images (100x100 JPEGs)
├── models/                       # Model specs
│   └── eby_user_spec.rb         # ✅ Complete (46 examples)
├── controllers/                  # Controller specs (TODO)
├── requests/                     # Request/integration specs (TODO)
├── system/                       # System/feature specs (TODO)
├── lib/                         # Library specs (TODO)
├── support/                     # Shared test configuration
│   ├── database_cleaner.rb     # DB cleaning strategy
│   ├── factory_bot.rb          # FactoryBot configuration
│   ├── image_helpers.rb        # Test image generation
│   ├── shoulda_matchers.rb     # Shoulda configuration
│   ├── vcr.rb                  # VCR configuration for OAuth
│   ├── shared_contexts/
│   │   ├── authenticated_user.rb    # Auth context helpers
│   │   └── oauth_mock.rb            # OAuth mocking
│   └── shared_examples/
│       ├── auditable.rb             # Audit trail verification
│       ├── requires_authentication.rb
│       └── requires_role.rb         # Role-based access control tests
├── vcr_cassettes/               # Recorded HTTP interactions
├── rails_helper.rb              # Rails-specific RSpec config
└── spec_helper.rb               # General RSpec config + SimpleCov
```

## Test Factories

### EbyUser Factory

Creates test users with various roles and capabilities:

```ruby
# Basic user
user = create(:eby_user)

# User with specific roles
typist = create(:eby_user, :typist)
proofer = create(:eby_user, :proofer, :proof_level_2)
admin = create(:eby_user, :admin)  # All roles

# User with language capabilities
arabic_typist = create(:eby_user, :typist, :with_arabic)
multilingual = create(:eby_user, :fixer, :with_all_languages)

# OAuth user
oauth_user = create(:eby_user, :from_google_oauth)
```

### EbyDef Factory

Creates test definitions in various states:

```ruby
# Basic definition
def = create(:eby_def)

# Definition in specific status
need_typing = create(:eby_def, :need_typing)
need_proof = create(:eby_def, :need_proof_2)
published = create(:eby_def, :published)

# Definition with size (number of parts)
small_def = create(:eby_def, :small)    # 1 part
medium_def = create(:eby_def, :medium)  # 2 parts
large_def = create(:eby_def, :large)    # 5 parts

# Definition needing fixup
arabic_fixup = create(:eby_def, :need_fixup, :arabic_todo)
```

### Image Factories

Creates test images with ActiveStorage attachments:

```ruby
# Scan image
scan = create(:eby_scan_image)
partitioned_scan = create(:eby_scan_image, :partitioned)

# Column image
column = create(:eby_column_image)
ready_column = create(:eby_column_image, :need_def_partition)

# Definition part image
part = create(:eby_def_part_image)
last_part = create(:eby_def_part_image, :last_part)
```

## Shared Examples

Use shared examples for common behavior:

```ruby
# Authentication requirement
it_behaves_like 'requires authentication' do
  subject { get :index }
end

# Role-based access
it_behaves_like 'requires role', 'publisher' do
  subject { post :publish, params: { id: def_id } }
end

# Audit trail verification
it_behaves_like 'creates audit event', 'typing_completed',
  from_status: 'NeedTyping',
  to_status: 'NeedProof1' do
  subject { post :processtype, params: { action: 'save_and_done' } }
end
```

## Shared Contexts

Use shared contexts for common setups:

```ruby
# Authenticated user
RSpec.describe TypeController do
  include_context 'authenticated typist'

  it 'assigns work' do
    get :get_def
    expect(assigns(:def)).to be_present
  end
end

# OAuth mocking
RSpec.describe SessionsController do
  include_context 'oauth mock'

  it 'logs in via Google' do
    post :create
    expect(session[:user_id]).to be_present
  end
end
```

## Testing Patterns

### Testing Complex SQL Queries

```ruby
describe '.query_by_user_size_and_action' do
  it 'generates valid SQL for typing assignment' do
    sql = EbyDef.query_by_user_size_and_action(user, 'small', action_type, nil)
    expect(sql).to include('WHERE')
    expect(sql).to include('NeedTyping')
  end

  it 'returns definitions ordered by reject_count' do
    create(:eby_def, :need_typing, :small, reject_count: 3)
    create(:eby_def, :need_typing, :small, reject_count: 1)

    sql = 'select eby_defs.* ' + EbyDef.query_by_user_size_and_action(user, 'small', type_action, nil)
    result = EbyDef.find_by_sql(sql)

    expect(result.first.reject_count).to eq(1)
  end
end
```

### Testing State Transitions

```ruby
describe '#processtype with save_and_done' do
  let(:definition) { create(:eby_def, :need_typing, :assigned) }

  it 'transitions to NeedProof1' do
    expect {
      post :processtype, params: { id: definition.id, commit: 'save_and_done' }
      definition.reload
    }.to change(definition, :status).from('NeedTyping').to('NeedProof')
      .and change(definition, :proof_round_passed).from(0).to(0)
  end

  it_behaves_like 'creates audit event', 'typing_completed'
end
```

### Testing Hebrew Text

```ruby
it 'strips nikkud from headword' do
  def_with_nikkud = create(:eby_def, defhead: 'בְּרֵאשִׁית')
  def.generate_aliases

  expect(def.aliases.first.alias).to eq('בראשית')
end
```

### Testing Image Processing

```ruby
it 'generates smalljpeg from origjpeg' do
  scan = create(:eby_scan_image)

  expect {
    scan.generate_small_jpeg
  }.to change { scan.cloud_smalljpeg.attached? }.from(false).to(true)
end
```

## OAuth Testing

OAuth is mocked using OmniAuth test mode:

```ruby
# In spec/support/shared_contexts/oauth_mock.rb
OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
  provider: 'google_oauth2',
  uid: '123456789',
  info: { name: 'Test User', email: 'test@example.com' }
})
```

For recording real OAuth flows (development only), use VCR cassettes.

## Performance Considerations

- Test suite should run in under 5 minutes
- Tag slow tests with `:slow` metadata
- Consider `parallel_tests` gem if suite grows large
- Use `let` instead of `let!` when possible to avoid unnecessary setup
- Use `build` instead of `create` when database persistence isn't needed

## Continuous Integration

The test suite is designed to run in CI environments. Add to your CI configuration:

```yaml
# .github/workflows/test.yml
- name: Set up test database
  run: RAILS_ENV=test bundle exec rake test_db:setup

- name: Run tests
  run: bundle exec rspec

- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/.resultset.json
```

## Troubleshooting

### Database Issues

If you see "table not found" errors:
```bash
RAILS_ENV=test bundle exec rake test_db:setup
```

### Image Fixture Issues

If image tests fail, regenerate fixtures:
```bash
bundle exec rspec  # Images auto-generate on first run
```

### Coverage Too Low

To identify uncovered code:
```bash
bundle exec rspec
open coverage/index.html
# Look for red/yellow highlighted code
```

### Factory Issues

If factories fail validation:
```bash
bundle exec rspec --only-failures
# Check factory definitions in spec/factories/
```

## Next Steps

### Phase 3: Complete Model Tests (In Progress)
- [x] EbyUser (46 examples, 100% coverage)
- [ ] EbyDef (most complex, ~200 examples expected)
- [ ] EbyDefEvent
- [ ] EbyScanImage, EbyColumnImage, EbyDefPartImage
- [ ] EbyAlias, EbyMarker

### Phase 4: Controller Tests
- [ ] ApplicationController
- [ ] SessionsController (OAuth)
- [ ] LoginController
- [ ] TypeController (main workflow)
- [ ] ScanController (most complex)
- [ ] DefinitionController
- [ ] UserController, AdminController, ProblemController, EbyAliasesController

### Phase 5: Integration Tests
- [ ] Typing workflow
- [ ] Proofing workflow
- [ ] Partitioning workflow
- [ ] Publishing workflow
- [ ] Authentication flow

### Phase 6: Library Tests
- [ ] EbyUtils module
- [ ] Application helpers

### Phase 7: System Tests (Optional)
- [ ] User login
- [ ] Definition typing
- [ ] Scan partitioning

### Phase 8: Polish
- [ ] Achieve 80%+ coverage
- [ ] Documentation
- [ ] CI setup
- [ ] Migrate from Minitest

## Contributing

When adding new tests:

1. **Use descriptive test names**: `it 'assigns definition to user with lowest reject_count'`
2. **Follow AAA pattern**: Arrange, Act, Assert
3. **One assertion per test** (when practical)
4. **Use factories** instead of fixtures
5. **Tag slow tests**: `it 'processes large image', :slow do`
6. **Keep tests DRY** with shared examples/contexts
7. **Test behavior, not implementation**

## Resources

- [RSpec Documentation](https://rspec.info/)
- [FactoryBot Getting Started](https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md)
- [Shoulda Matchers](https://github.com/thoughtbot/shoulda-matchers)
- [Better Specs](https://www.betterspecs.org/)
