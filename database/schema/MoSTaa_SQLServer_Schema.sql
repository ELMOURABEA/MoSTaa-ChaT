-- MoSTaa-ChaT v1.0.0
-- Complete SQL Server Schema for Enterprise Omnichannel Communications Platform
-- Database: MoSTaaChat_Production
-- Created: 2026-10-11
-- Purpose: Multi-tenant SaaS platform for healthcare, enterprise, and business communications

-- ============================================================================
-- SECTION 1: CORE INFRASTRUCTURE TABLES
-- ============================================================================

-- Organizations/Companies
CREATE TABLE Companies (
    CompanyId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyName NVARCHAR(255) NOT NULL,
    CompanyCode NVARCHAR(50) UNIQUE NOT NULL,
    CompanyDomain NVARCHAR(255),
    IndustryType NVARCHAR(100), -- healthcare, retail, saas, fintech, etc
    CompanySize NVARCHAR(50), -- small, medium, large, enterprise
    LogoUrl NVARCHAR(500),
    BrandColor NVARCHAR(7), -- hex color
    TimeZone NVARCHAR(100),
    Country NVARCHAR(100),
    State NVARCHAR(100),
    City NVARCHAR(100),
    Address NVARCHAR(500),
    Phone NVARCHAR(20),
    Email NVARCHAR(255),
    Website NVARCHAR(500),
    Status NVARCHAR(20), -- active, inactive, suspended, trial
    BillingPlanId BIGINT,
    MaxTeams INT DEFAULT 5,
    MaxAgents INT DEFAULT 50,
    MaxWhatsAppNumbers INT DEFAULT 10,
    MaxProductsInCatalog INT DEFAULT 1000,
    IsTrialAccount BIT DEFAULT 1,
    TrialExpiresAt DATETIME,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT,
    UpdatedBy BIGINT,
    IsDeleted BIT DEFAULT 0,
    DeletedAt DATETIME
);

-- Teams within Companies
CREATE TABLE Teams (
    TeamId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    TeamName NVARCHAR(255) NOT NULL,
    TeamCode NVARCHAR(50),
    TeamType NVARCHAR(50), -- support, sales, operations, healthcare, billing, custom
    Description NVARCHAR(500),
    TeamLeaderId BIGINT,
    MaxMembers INT DEFAULT 20,
    Status NVARCHAR(20), -- active, inactive, archived
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId)
);

-- Users/Employees
CREATE TABLE Users (
    UserId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    TeamId BIGINT,
    FirstName NVARCHAR(255) NOT NULL,
    LastName NVARCHAR(255),
    Email NVARCHAR(255) UNIQUE NOT NULL,
    PhoneNumber NVARCHAR(20),
    ProfileImageUrl NVARCHAR(500),
    JobTitle NVARCHAR(255),
    Department NVARCHAR(100),
    Status NVARCHAR(20), -- active, inactive, on_leave, archived
    IsOnline BIT DEFAULT 0,
    LastSeenAt DATETIME,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (TeamId) REFERENCES Teams(TeamId)
);

-- Roles and Permissions
CREATE TABLE Roles (
    RoleId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    RoleName NVARCHAR(100) NOT NULL,
    RoleCode NVARCHAR(50),
    Description NVARCHAR(500),
    PermissionLevel INT, -- 1=customer, 2=agent, 3=supervisor, 4=manager, 5=admin
    CreatedAt DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId)
);

-- User Roles
CREATE TABLE UserRoles (
    UserRoleId BIGINT PRIMARY KEY IDENTITY(1,1),
    UserId BIGINT NOT NULL,
    RoleId BIGINT NOT NULL,
    AssignedAt DATETIME DEFAULT GETDATE(),
    AssignedBy BIGINT,
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (RoleId) REFERENCES Roles(RoleId),
    UNIQUE(UserId, RoleId)
);

-- Authentication Providers
CREATE TABLE AuthProviders (
    AuthProviderId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    ProviderType NVARCHAR(50), -- google, facebook, gmail, microsoft, custom
    ProviderName NVARCHAR(255),
    ClientId NVARCHAR(500),
    ClientSecret NVARCHAR(500), -- encrypted
    RedirectUrl NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    IsVerified BIT DEFAULT 0,
    VerificationTokens NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId)
);

-- ============================================================================
-- SECTION 2: CUSTOMER & CONTACT MANAGEMENT
-- ============================================================================

-- Customers
CREATE TABLE Customers (
    CustomerId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    FirstName NVARCHAR(255),
    LastName NVARCHAR(255),
    Email NVARCHAR(255),
    PhoneNumber NVARCHAR(20),
    WhatsAppNumber NVARCHAR(20),
    CustomerStatus NVARCHAR(50), -- active, inactive, blocked, prospect, lead, customer
    CustomerSource NVARCHAR(100), -- whatsapp, website, facebook, phone, referral
    PreferredChannel NVARCHAR(50), -- whatsapp, sms, email, voice
    ConsentStatus NVARCHAR(20), -- given, pending, revoked
    ConsentVerifiedAt DATETIME,
    PatientId NVARCHAR(100), -- for healthcare
    MedicalRecordId NVARCHAR(100), -- for healthcare
    Metadata NVARCHAR(MAX), -- JSON: custom fields
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    LastContactedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId)
);

-- Customer Contacts
CREATE TABLE CustomerContacts (
    ContactId BIGINT PRIMARY KEY IDENTITY(1,1),
    CustomerId BIGINT NOT NULL,
    ContactType NVARCHAR(50), -- primary, billing, emergency, healthcare_provider
    Name NVARCHAR(255),
    PhoneNumber NVARCHAR(20),
    Email NVARCHAR(255),
    Relationship NVARCHAR(100),
    IsPreferred BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId)
);

-- ============================================================================
-- SECTION 3: WHATSAPP & COMMUNICATION CHANNELS
-- ============================================================================

-- WhatsApp Numbers (Company-owned)
CREATE TABLE WhatsAppNumbers (
    WhatsAppNumberId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    TeamId BIGINT,
    PhoneNumber NVARCHAR(20) UNIQUE NOT NULL,
    CountryCode NVARCHAR(5),
    CountryName NVARCHAR(100),
    DisplayName NVARCHAR(255),
    Status NVARCHAR(20), -- active, inactive, verified, pending
    IsVerified BIT DEFAULT 0,
    VerifiedAt DATETIME,
    MessageTemplate NVARCHAR(MAX),
    GreetingMessage NVARCHAR(500),
    AwayMessage NVARCHAR(500),
    MaxDailyMessages INT DEFAULT 1000,
    DailyMessageCount INT DEFAULT 0,
    ResetCountAt DATETIME,
    WebhookUrl NVARCHAR(500),
    WebhookToken NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (TeamId) REFERENCES Teams(TeamId)
);

-- Social Media Accounts
CREATE TABLE SocialMediaAccounts (
    SocialAccountId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    TeamId BIGINT,
    Platform NVARCHAR(50), -- facebook, instagram, twitter, linkedin, telegram
    PlatformAccountId NVARCHAR(255),
    AccountName NVARCHAR(255),
    AccessToken NVARCHAR(MAX), -- encrypted
    RefreshToken NVARCHAR(MAX), -- encrypted
    ExpiresAt DATETIME,
    Status NVARCHAR(20), -- active, inactive, disconnected
    IsVerified BIT DEFAULT 0,
    FollowerCount INT,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (TeamId) REFERENCES Teams(TeamId)
);

-- ============================================================================
-- SECTION 4: CONVERSATIONS & MESSAGING
-- ============================================================================

-- Conversations
CREATE TABLE Conversations (
    ConversationId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    CustomerId BIGINT NOT NULL,
    TeamId BIGINT,
    PrimaryAgentId BIGINT,
    SupervisorId BIGINT,
    Channel NVARCHAR(50), -- whatsapp, sms, email, website, facebook, instagram, voice
    Status NVARCHAR(50), -- active, waiting, in_progress, resolved, closed, escalated
    Priority NVARCHAR(20), -- low, medium, high, urgent
    Subject NVARCHAR(500),
    Description NVARCHAR(MAX),
    ConversationType NVARCHAR(50), -- support, sales, appointment, complaint, inquiry, healthcare_intake
    AssignedAt DATETIME,
    StartedAt DATETIME DEFAULT GETDATE(),
    ResolvedAt DATETIME,
    ClosedAt DATETIME,
    FirstResponseTime INT, -- minutes
    ResolutionTime INT, -- minutes
    CustomerSatisfactionRating INT, -- 1-5
    SatisfactionComment NVARCHAR(500),
    Tags NVARCHAR(MAX), -- JSON array
    Metadata NVARCHAR(MAX), -- JSON: custom fields
    IsEscalated BIT DEFAULT 0,
    EscalatedAt DATETIME,
    EscalationReason NVARCHAR(500),
    IsAIResolved BIT DEFAULT 0,
    AIConfidenceScore DECIMAL(3,2),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
    FOREIGN KEY (TeamId) REFERENCES Teams(TeamId),
    FOREIGN KEY (PrimaryAgentId) REFERENCES Users(UserId),
    FOREIGN KEY (SupervisorId) REFERENCES Users(UserId)
);

-- Messages
CREATE TABLE Messages (
    MessageId BIGINT PRIMARY KEY IDENTITY(1,1),
    ConversationId BIGINT NOT NULL,
    CompanyId BIGINT NOT NULL,
    SenderId BIGINT, -- UserId for agent, CustomerId for customer
    SenderType NVARCHAR(20), -- agent, customer, system, ai
    MessageContent NVARCHAR(MAX),
    MessageType NVARCHAR(50), -- text, image, video, audio, document, file, template
    ContentUrl NVARCHAR(500),
    MediaMimeType NVARCHAR(100),
    MediaSize BIGINT,
    Metadata NVARCHAR(MAX), -- JSON
    MessageStatus NVARCHAR(20), -- sent, delivered, read, failed
    DeliveredAt DATETIME,
    ReadAt DATETIME,
    FailureReason NVARCHAR(500),
    IsForwarded BIT DEFAULT 0,
    OriginalMessageId BIGINT,
    HasAttachment BIT DEFAULT 0,
    AttachmentCount INT DEFAULT 0,
    ReplyToMessageId BIGINT,
    IsTemplate BIT DEFAULT 0,
    TemplateId BIGINT,
    IsAutomated BIT DEFAULT 0,
    AutomationRuleId BIGINT,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (ConversationId) REFERENCES Conversations(ConversationId),
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (TemplateId) REFERENCES MessageTemplates(TemplateId),
    FOREIGN KEY (ReplyToMessageId) REFERENCES Messages(MessageId)
);

-- Message Status Tracking
CREATE TABLE MessageStatus (
    MessageStatusId BIGINT PRIMARY KEY IDENTITY(1,1),
    MessageId BIGINT NOT NULL,
    Status NVARCHAR(20), -- sent, delivered, read, failed
    UpdatedAt DATETIME DEFAULT GETDATE(),
    UpdatedBy BIGINT,
    StatusReason NVARCHAR(500),
    FOREIGN KEY (MessageId) REFERENCES Messages(MessageId)
);

-- Message Templates
CREATE TABLE MessageTemplates (
    TemplateId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    TemplateName NVARCHAR(255),
    TemplateCategory NVARCHAR(100), -- greeting, support, sales, appointment, reminder
    TemplateContent NVARCHAR(MAX),
    TemplateVariables NVARCHAR(MAX), -- JSON array of variable names
    ApprovalStatus NVARCHAR(20), -- draft, pending, approved, rejected
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT,
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId)
);

-- ============================================================================
-- SECTION 5: PRODUCT CATALOG & ORDERS
-- ============================================================================

-- Product Categories
CREATE TABLE ProductCategories (
    CategoryId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    CategoryName NVARCHAR(255) NOT NULL,
    CategoryCode NVARCHAR(50),
    Description NVARCHAR(500),
    ParentCategoryId BIGINT,
    ImageUrl NVARCHAR(500),
    DisplayOrder INT,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (ParentCategoryId) REFERENCES ProductCategories(CategoryId)
);

-- Products
CREATE TABLE Products (
    ProductId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    CategoryId BIGINT,
    ProductName NVARCHAR(255) NOT NULL,
    ProductCode NVARCHAR(100) UNIQUE,
    SKU NVARCHAR(100),
    Description NVARCHAR(MAX),
    LongDescription NVARCHAR(MAX),
    UnitPrice DECIMAL(10,2),
    CurrencyCode NVARCHAR(3), -- USD, EUR, etc
    CostPrice DECIMAL(10,2),
    Quantity INT,
    ReorderLevel INT,
    ImageUrl NVARCHAR(500),
    AdditionalImages NVARCHAR(MAX), -- JSON array of URLs
    Tags NVARCHAR(MAX), -- JSON array
    Status NVARCHAR(20), -- active, inactive, discontinued, draft
    IsDigital BIT DEFAULT 0,
    DownloadUrl NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT,
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (CategoryId) REFERENCES ProductCategories(CategoryId)
);

-- Product Variants
CREATE TABLE ProductVariants (
    VariantId BIGINT PRIMARY KEY IDENTITY(1,1),
    ProductId BIGINT NOT NULL,
    VariantName NVARCHAR(255),
    VariantCode NVARCHAR(100),
    VariantPrice DECIMAL(10,2),
    VariantQuantity INT,
    Attributes NVARCHAR(MAX), -- JSON: {color, size, etc}
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);

-- Orders
CREATE TABLE Orders (
    OrderId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    CustomerId BIGINT NOT NULL,
    ConversationId BIGINT,
    OrderNumber NVARCHAR(100) UNIQUE,
    OrderStatus NVARCHAR(50), -- pending, confirmed, processing, shipped, delivered, cancelled, refunded
    OrderDate DATETIME DEFAULT GETDATE(),
    DeliveryDate DATETIME,
    TotalAmount DECIMAL(10,2),
    TaxAmount DECIMAL(10,2),
    ShippingCost DECIMAL(10,2),
    DiscountAmount DECIMAL(10,2),
    FinalAmount DECIMAL(10,2),
    CurrencyCode NVARCHAR(3),
    PaymentStatus NVARCHAR(50), -- pending, completed, failed, refunded
    PaymentMethod NVARCHAR(50), -- credit_card, bank_transfer, wallet, cash
    ShippingAddress NVARCHAR(MAX), -- JSON
    BillingAddress NVARCHAR(MAX), -- JSON
    TrackingNumber NVARCHAR(100),
    Notes NVARCHAR(500),
    AgentId BIGINT,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
    FOREIGN KEY (ConversationId) REFERENCES Conversations(ConversationId),
    FOREIGN KEY (AgentId) REFERENCES Users(UserId)
);

-- Order Items
CREATE TABLE OrderItems (
    OrderItemId BIGINT PRIMARY KEY IDENTITY(1,1),
    OrderId BIGINT NOT NULL,
    ProductId BIGINT,
    VariantId BIGINT,
    ProductName NVARCHAR(255),
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    LineTotal DECIMAL(10,2),
    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    FOREIGN KEY (VariantId) REFERENCES ProductVariants(VariantId)
);

-- ============================================================================
-- SECTION 6: SALES & LEADS
-- ============================================================================

-- Leads
CREATE TABLE Leads (
    LeadId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    CustomerId BIGINT,
    TeamId BIGINT,
    AgentId BIGINT,
    ConversationId BIGINT,
    LeadSource NVARCHAR(100), -- whatsapp, website, facebook, phone, referral, campaign
    LeadStatus NVARCHAR(50), -- new, contacted, qualified, proposal, negotiation, won, lost
    LeadScore INT, -- 0-100
    ProductInterest NVARCHAR(MAX), -- JSON array of product IDs
    EstimatedValue DECIMAL(10,2),
    ExpectedClosureDate DATETIME,
    NextFollowUpDate DATETIME,
    Notes NVARCHAR(MAX),
    Tags NVARCHAR(MAX), -- JSON array
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    ClosedAt DATETIME,
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
    FOREIGN KEY (TeamId) REFERENCES Teams(TeamId),
    FOREIGN KEY (AgentId) REFERENCES Users(UserId),
    FOREIGN KEY (ConversationId) REFERENCES Conversations(ConversationId)
);

-- Lead Activities
CREATE TABLE LeadActivities (
    ActivityId BIGINT PRIMARY KEY IDENTITY(1,1),
    LeadId BIGINT NOT NULL,
    ActivityType NVARCHAR(50), -- call, email, meeting, proposal, follow_up
    ActivityDescription NVARCHAR(MAX),
    ScheduledDate DATETIME,
    CompletedDate DATETIME,
    AgentId BIGINT,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (LeadId) REFERENCES Leads(LeadId),
    FOREIGN KEY (AgentId) REFERENCES Users(UserId)
);

-- ============================================================================
-- SECTION 7: AI & AUTOMATION
-- ============================================================================

-- AI Interactions
CREATE TABLE AIInteractions (
    AIInteractionId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    ConversationId BIGINT NOT NULL,
    CustomerId BIGINT,
    AgentId BIGINT,
    AIModelVersion NVARCHAR(100),
    UserMessage NVARCHAR(MAX),
    AIResponse NVARCHAR(MAX),
    ConfidenceScore DECIMAL(3,2),
    WasHelpful BIT,
    FeedbackScore INT, -- 1-5
    FeedbackComments NVARCHAR(500),
    RequiredHumanHandoff BIT DEFAULT 0,
    HandoffReason NVARCHAR(500),
    ResolutionType NVARCHAR(50), -- ai_resolved, human_resolved, escalated
    ProcessingTimeMs INT,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (ConversationId) REFERENCES Conversations(ConversationId),
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
    FOREIGN KEY (AgentId) REFERENCES Users(UserId)
);

-- Automation Rules
CREATE TABLE AutomationRules (
    RuleId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    TeamId BIGINT,
    RuleName NVARCHAR(255),
    RuleDescription NVARCHAR(500),
    TriggerType NVARCHAR(50), -- message_received, conversation_created, customer_tag, time_based
    Conditions NVARCHAR(MAX), -- JSON: array of conditions
    Actions NVARCHAR(MAX), -- JSON: array of actions
    Priority INT,
    IsActive BIT DEFAULT 1,
    IsDefault BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CreatedBy BIGINT,
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (TeamId) REFERENCES Teams(TeamId)
);

-- ============================================================================
-- SECTION 8: VOICE & VIDEO
-- ============================================================================

-- Voice Records
CREATE TABLE VoiceRecords (
    VoiceRecordId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    ConversationId BIGINT,
    CustomerId BIGINT,
    AgentId BIGINT,
    CallType NVARCHAR(20), -- inbound, outbound, voicemail
    CallStatus NVARCHAR(50), -- initiated, ringing, answered, completed, missed, declined
    CallDuration INT, -- seconds
    RecordingUrl NVARCHAR(500),
    RecordingDuration INT, -- seconds
    TranscriptUrl NVARCHAR(500),
    Transcript NVARCHAR(MAX),
    StartedAt DATETIME,
    EndedAt DATETIME,
    QualityScore INT, -- 1-100
    Notes NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (ConversationId) REFERENCES Conversations(ConversationId),
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
    FOREIGN KEY (AgentId) REFERENCES Users(UserId)
);

-- Video Requests
CREATE TABLE VideoRequests (
    VideoRequestId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    ConversationId BIGINT,
    CustomerId BIGINT,
    AgentId BIGINT,
    RequestedAt DATETIME DEFAULT GETDATE(),
    AcceptedAt DATETIME,
    DeclinedAt DATETIME,
    StartedAt DATETIME,
    EndedAt DATETIME,
    Duration INT, -- seconds
    RecordingUrl NVARCHAR(500),
    RoomUrl NVARCHAR(500),
    Status NVARCHAR(50), -- pending, accepted, in_progress, completed, declined, expired
    DeclineReason NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (ConversationId) REFERENCES Conversations(ConversationId),
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
    FOREIGN KEY (AgentId) REFERENCES Users(UserId)
);

-- ============================================================================
-- SECTION 9: WEBSITE INTEGRATION
-- ============================================================================

-- Website Configurations
CREATE TABLE WebsiteConfigurations (
    WebsiteConfigId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    TeamId BIGINT,
    WebsiteUrl NVARCHAR(500),
    EmbedCode NVARCHAR(MAX), -- JavaScript embed code
    WidgetPosition NVARCHAR(50), -- bottom-right, bottom-left, top-right, top-left
    WidgetColor NVARCHAR(7), -- hex color
    WidgetOpacity DECIMAL(3,2), -- 0-1
    GreetingMessage NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (TeamId) REFERENCES Teams(TeamId)
);

-- Website Visitors
CREATE TABLE WebsiteVisitors (
    VisitorId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    VisitorSessionId NVARCHAR(255) UNIQUE,
    VisitorEmail NVARCHAR(255),
    VisitorName NVARCHAR(255),
    VisitorPhoneNumber NVARCHAR(20),
    VisitorIpAddress NVARCHAR(50),
    VisitorBrowser NVARCHAR(255),
    VisitorDevice NVARCHAR(100),
    PageUrl NVARCHAR(500),
    ReferrerUrl NVARCHAR(500),
    VisitDuration INT, -- seconds
    HasChatted BIT DEFAULT 0,
    ChatStartedAt DATETIME,
    ConversationId BIGINT,
    VisitedAt DATETIME DEFAULT GETDATE(),
    LeftAt DATETIME,
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (ConversationId) REFERENCES Conversations(ConversationId)
);

-- ============================================================================
-- SECTION 10: BILLING & SUBSCRIPTION
-- ============================================================================

-- Billing Plans
CREATE TABLE BillingPlans (
    BillingPlanId BIGINT PRIMARY KEY IDENTITY(1,1),
    PlanName NVARCHAR(100),
    PlanCode NVARCHAR(50) UNIQUE,
    Description NVARCHAR(MAX),
    MonthlyCost DECIMAL(10,2),
    YearlyCost DECIMAL(10,2),
    MaxTeams INT,
    MaxAgents INT,
    MaxWhatsAppNumbers INT,
    MaxProductsInCatalog INT,
    IncludesAI BIT,
    IncludesAnalytics BIT,
    IncludesVideoCall BIT,
    IncludesVoice BIT,
    IncludesAPI BIT,
    SupportLevel NVARCHAR(50), -- basic, standard, premium, enterprise
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Subscriptions
CREATE TABLE Subscriptions (
    SubscriptionId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    BillingPlanId BIGINT NOT NULL,
    SubscriptionStatus NVARCHAR(50), -- active, paused, cancelled, trial
    StartDate DATETIME,
    EndDate DATETIME,
    RenewalDate DATETIME,
    BillingCycleMonths INT DEFAULT 1,
    AmountPaid DECIMAL(10,2),
    PaymentMethod NVARCHAR(50),
    PaymentGatewayId NVARCHAR(100),
    AutoRenew BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    CancelledAt DATETIME,
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (BillingPlanId) REFERENCES BillingPlans(BillingPlanId)
);

-- Invoices
CREATE TABLE Invoices (
    InvoiceId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    SubscriptionId BIGINT,
    InvoiceNumber NVARCHAR(100) UNIQUE,
    InvoiceDate DATETIME,
    DueDate DATETIME,
    Amount DECIMAL(10,2),
    TaxAmount DECIMAL(10,2),
    TotalAmount DECIMAL(10,2),
    Status NVARCHAR(50), -- draft, sent, paid, overdue, cancelled
    PaymentReceivedDate DATETIME,
    PdfUrl NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (SubscriptionId) REFERENCES Subscriptions(SubscriptionId)
);

-- ============================================================================
-- SECTION 11: HEALTHCARE SPECIFIC
-- ============================================================================

-- Healthcare Appointments
CREATE TABLE HealthcareAppointments (
    AppointmentId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    CustomerId BIGINT NOT NULL,
    TeamId BIGINT,
    AgentId BIGINT,
    ConversationId BIGINT,
    AppointmentDate DATETIME,
    AppointmentEndTime DATETIME,
    AppointmentType NVARCHAR(100), -- consultation, checkup, procedure, follow_up
    Status NVARCHAR(50), -- scheduled, confirmed, completed, cancelled, no_show
    ProviderName NVARCHAR(255),
    Location NVARCHAR(500),
    Notes NVARCHAR(MAX),
    ReminderSentAt DATETIME,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
    FOREIGN KEY (TeamId) REFERENCES Teams(TeamId),
    FOREIGN KEY (AgentId) REFERENCES Users(UserId),
    FOREIGN KEY (ConversationId) REFERENCES Conversations(ConversationId)
);

-- Healthcare Consent & Privacy
CREATE TABLE HealthcareConsent (
    ConsentId BIGINT PRIMARY KEY IDENTITY(1,1),
    CustomerId BIGINT NOT NULL,
    CompanyId BIGINT NOT NULL,
    ConsentType NVARCHAR(100), -- communication, data_processing, medical_record_access
    ConsentStatus NVARCHAR(50), -- given, revoked, pending
    ConsentDate DATETIME,
    RevokedDate DATETIME,
    DocumentUrl NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId)
);

-- ============================================================================
-- SECTION 12: AUDIT & LOGGING
-- ============================================================================

-- Audit Logs
CREATE TABLE AuditLogs (
    AuditLogId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    UserId BIGINT,
    Action NVARCHAR(255), -- create, update, delete, login, export
    EntityType NVARCHAR(100), -- conversation, message, customer, order
    EntityId BIGINT,
    OldValues NVARCHAR(MAX), -- JSON
    NewValues NVARCHAR(MAX), -- JSON
    IpAddress NVARCHAR(50),
    UserAgent NVARCHAR(500),
    Status NVARCHAR(50), -- success, failure
    ErrorMessage NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

-- Activity Logs
CREATE TABLE ActivityLogs (
    ActivityLogId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    UserId BIGINT,
    ActivityType NVARCHAR(100), -- login, logout, message_sent, call_made, export
    ConversationId BIGINT,
    CustomerId BIGINT,
    Details NVARCHAR(MAX), -- JSON
    Duration INT, -- seconds (for calls, sessions)
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (ConversationId) REFERENCES Conversations(ConversationId),
    FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId)
);

-- ============================================================================
-- SECTION 13: ANALYTICS & REPORTING
-- ============================================================================

-- Daily Analytics Snapshots
CREATE TABLE DailyAnalyticsSnapshots (
    SnapshotId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    TeamId BIGINT,
    SnapshotDate DATE,
    TotalConversations INT DEFAULT 0,
    ActiveConversations INT DEFAULT 0,
    ResolvedConversations INT DEFAULT 0,
    UnresolvedConversations INT DEFAULT 0,
    TotalMessages INT DEFAULT 0,
    AvgResponseTime INT, -- seconds
    AvgResolutionTime INT, -- seconds
    TotalLeadsGenerated INT DEFAULT 0,
    TotalOrdersGenerated INT DEFAULT 0,
    TotalOrderValue DECIMAL(10,2),
    TotalCustomers INT DEFAULT 0,
    NewCustomers INT DEFAULT 0,
    AvgSatisfactionScore DECIMAL(3,2),
    AgentOnlineTime INT, -- minutes
    AgentUtilization DECIMAL(5,2), -- percentage
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (TeamId) REFERENCES Teams(TeamId)
);

-- Agent Performance Metrics
CREATE TABLE AgentPerformanceMetrics (
    MetricId BIGINT PRIMARY KEY IDENTITY(1,1),
    CompanyId BIGINT NOT NULL,
    AgentId BIGINT NOT NULL,
    MetricDate DATE,
    ConversationsHandled INT DEFAULT 0,
    ConversationsResolved INT DEFAULT 0,
    AvgResponseTime INT, -- seconds
    AvgResolutionTime INT, -- seconds
    CustomerSatisfactionScore DECIMAL(3,2),
    TotalCallTime INT, -- minutes
    TotalMessagingTime INT, -- minutes
    LeadsGenerated INT DEFAULT 0,
    OrdersGenerated INT DEFAULT 0,
    OrderValue DECIMAL(10,2),
    Quality Score INT, -- 1-100
    Adherence DECIMAL(5,2), -- percentage
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CompanyId) REFERENCES Companies(CompanyId),
    FOREIGN KEY (AgentId) REFERENCES Users(UserId)
);

-- ============================================================================
-- SECTION 14: INDEXES FOR PERFORMANCE
-- ============================================================================

-- Conversation Indexes
CREATE INDEX idx_conversations_company_team ON Conversations(CompanyId, TeamId);
CREATE INDEX idx_conversations_customer ON Conversations(CustomerId);
CREATE INDEX idx_conversations_agent ON Conversations(PrimaryAgentId);
CREATE INDEX idx_conversations_status ON Conversations(Status);
CREATE INDEX idx_conversations_created ON Conversations(CreatedAt);

-- Message Indexes
CREATE INDEX idx_messages_conversation ON Messages(ConversationId);
CREATE INDEX idx_messages_company ON Messages(CompanyId);
CREATE INDEX idx_messages_created ON Messages(CreatedAt);
CREATE INDEX idx_messages_status ON Messages(MessageStatus);

-- Customer Indexes
CREATE INDEX idx_customers_company ON Customers(CompanyId);
CREATE INDEX idx_customers_email ON Customers(Email);
CREATE INDEX idx_customers_phone ON Customers(PhoneNumber);
CREATE INDEX idx_customers_whatsapp ON Customers(WhatsAppNumber);

-- User Indexes
CREATE INDEX idx_users_company_team ON Users(CompanyId, TeamId);
CREATE INDEX idx_users_email ON Users(Email);

-- Order Indexes
CREATE INDEX idx_orders_company_customer ON Orders(CompanyId, CustomerId);
CREATE INDEX idx_orders_status ON Orders(OrderStatus);
CREATE INDEX idx_orders_date ON Orders(OrderDate);

-- Lead Indexes
CREATE INDEX idx_leads_company_team ON Leads(CompanyId, TeamId);
CREATE INDEX idx_leads_status ON Leads(LeadStatus);
CREATE INDEX idx_leads_customer ON Leads(CustomerId);

-- AI Interaction Indexes
CREATE INDEX idx_ai_interactions_conversation ON AIInteractions(ConversationId);
CREATE INDEX idx_ai_interactions_company ON AIInteractions(CompanyId);
CREATE INDEX idx_ai_interactions_created ON AIInteractions(CreatedAt);

-- Analytics Indexes
CREATE INDEX idx_daily_analytics_company_date ON DailyAnalyticsSnapshots(CompanyId, SnapshotDate);
CREATE INDEX idx_agent_metrics_agent_date ON AgentPerformanceMetrics(AgentId, MetricDate);

-- Audit Log Indexes
CREATE INDEX idx_audit_logs_company_date ON AuditLogs(CompanyId, CreatedAt);
CREATE INDEX idx_audit_logs_entity ON AuditLogs(EntityType, EntityId);

-- ============================================================================
-- SECTION 15: VIEWS FOR ANALYTICS & REPORTING
-- ============================================================================

-- View: Company Overview
CREATE VIEW vw_CompanyOverview AS
SELECT 
    c.CompanyId,
    c.CompanyName,
    COUNT(DISTINCT t.TeamId) as TeamCount,
    COUNT(DISTINCT u.UserId) as AgentCount,
    COUNT(DISTINCT wan.WhatsAppNumberId) as ActiveWhatsAppNumbers,
    COUNT(DISTINCT cust.CustomerId) as TotalCustomers,
    c.Status,
    c.BillingPlanId,
    c.CreatedAt
FROM Companies c
LEFT JOIN Teams t ON c.CompanyId = t.CompanyId AND t.IsDeleted = 0
LEFT JOIN Users u ON c.CompanyId = u.CompanyId AND u.IsDeleted = 0
LEFT JOIN WhatsAppNumbers wan ON c.CompanyId = wan.CompanyId AND wan.Status = 'active'
LEFT JOIN Customers cust ON c.CompanyId = cust.CompanyId AND cust.IsDeleted = 0
GROUP BY c.CompanyId, c.CompanyName, c.Status, c.BillingPlanId, c.CreatedAt;

-- View: Conversation Summary
CREATE VIEW vw_ConversationSummary AS
SELECT 
    c.ConversationId,
    c.CompanyId,
    cust.FirstName + ' ' + COALESCE(cust.LastName, '') as CustomerName,
    cust.PhoneNumber,
    c.Channel,
    c.Status,
    c.Priority,
    u.FirstName + ' ' + COALESCE(u.LastName, '') as AgentName,
    c.StartedAt,
    c.ResolvedAt,
    DATEDIFF(MINUTE, c.StartedAt, COALESCE(c.ResolvedAt, GETDATE())) as ResolutionMinutes,
    c.CustomerSatisfactionRating,
    COUNT(m.MessageId) as MessageCount
FROM Conversations c
LEFT JOIN Customers cust ON c.CustomerId = cust.CustomerId
LEFT JOIN Users u ON c.PrimaryAgentId = u.UserId
LEFT JOIN Messages m ON c.ConversationId = m.ConversationId
GROUP BY c.ConversationId, c.CompanyId, cust.FirstName, cust.LastName, 
         cust.PhoneNumber, c.Channel, c.Status, c.Priority, 
         u.FirstName, u.LastName, c.StartedAt, c.ResolvedAt, c.CustomerSatisfactionRating;

-- View: Team Performance
CREATE VIEW vw_TeamPerformance AS
SELECT 
    t.TeamId,
    t.TeamName,
    t.CompanyId,
    COUNT(DISTINCT u.UserId) as AgentCount,
    COUNT(DISTINCT c.ConversationId) as TotalConversations,
    SUM(CASE WHEN c.Status = 'resolved' THEN 1 ELSE 0 END) as ResolvedConversations,
    AVG(CAST(c.FirstResponseTime AS FLOAT)) as AvgFirstResponseTime,
    AVG(CAST(c.ResolutionTime AS FLOAT)) as AvgResolutionTime,
    AVG(CAST(c.CustomerSatisfactionRating AS FLOAT)) as AvgSatisfactionScore
FROM Teams t
LEFT JOIN Users u ON t.TeamId = u.TeamId
LEFT JOIN Conversations c ON t.TeamId = c.TeamId
GROUP BY t.TeamId, t.TeamName, t.CompanyId;

-- View: Sales Pipeline
CREATE VIEW vw_SalesPipeline AS
SELECT 
    l.LeadStatus,
    COUNT(*) as LeadCount,
    SUM(l.EstimatedValue) as TotalValue,
    AVG(l.EstimatedValue) as AvgValue,
    l.CompanyId
FROM Leads l
WHERE l.LeadStatus NOT IN ('won', 'lost')
GROUP BY l.LeadStatus, l.CompanyId;

-- ============================================================================
-- SECTION 16: STORED PROCEDURES FOR COMMON OPERATIONS
-- ============================================================================

-- Procedure: Get Conversation Summary
CREATE PROCEDURE sp_GetConversationSummary
    @ConversationId BIGINT,
    @CompanyId BIGINT
AS
BEGIN
    SELECT 
        c.*,
        cust.FirstName + ' ' + COALESCE(cust.LastName, '') as CustomerName,
        u.FirstName + ' ' + COALESCE(u.LastName, '') as AgentName,
        COUNT(m.MessageId) as MessageCount
    FROM Conversations c
    LEFT JOIN Customers cust ON c.CustomerId = cust.CustomerId
    LEFT JOIN Users u ON c.PrimaryAgentId = u.UserId
    LEFT JOIN Messages m ON c.ConversationId = m.ConversationId
    WHERE c.ConversationId = @ConversationId AND c.CompanyId = @CompanyId
    GROUP BY c.ConversationId, c.CompanyId, c.CustomerId, c.TeamId, c.PrimaryAgentId,
             c.SupervisorId, c.Channel, c.Status, c.Priority, c.Subject, c.Description,
             c.ConversationType, c.AssignedAt, c.StartedAt, c.ResolvedAt, c.ClosedAt,
             c.FirstResponseTime, c.ResolutionTime, c.CustomerSatisfactionRating,
             c.SatisfactionComment, c.Tags, c.Metadata, c.IsEscalated, c.EscalatedAt,
             c.EscalationReason, c.IsAIResolved, c.AIConfidenceScore, c.CreatedAt,
             c.UpdatedAt, c.IsDeleted, cust.FirstName, cust.LastName, u.FirstName, u.LastName;
END;

-- Procedure: Create new conversation with assignment
CREATE PROCEDURE sp_CreateConversationWithAssignment
    @CompanyId BIGINT,
    @CustomerId BIGINT,
    @Channel NVARCHAR(50),
    @ConversationType NVARCHAR(50),
    @TeamId BIGINT OUTPUT,
    @ConversationId BIGINT OUTPUT
AS
BEGIN
    BEGIN TRANSACTION
    
    -- Create conversation
    INSERT INTO Conversations (CompanyId, CustomerId, Channel, ConversationType, Status, Priority, StartedAt, CreatedAt, UpdatedAt)
    VALUES (@CompanyId, @CustomerId, @Channel, @ConversationType, 'active', 'medium', GETDATE(), GETDATE(), GETDATE())
    
    SET @ConversationId = SCOPE_IDENTITY()
    
    -- Find available team (round-robin or by availability)
    SELECT TOP 1 @TeamId = t.TeamId
    FROM Teams t
    WHERE t.CompanyId = @CompanyId AND t.Status = 'active'
    ORDER BY t.TeamId
    
    -- Assign to least busy agent in team
    DECLARE @AgentId BIGINT
    SELECT TOP 1 @AgentId = u.UserId
    FROM Users u
    WHERE u.TeamId = @TeamId AND u.Status = 'active'
    ORDER BY (SELECT COUNT(*) FROM Conversations WHERE PrimaryAgentId = u.UserId AND Status = 'active') ASC
    
    UPDATE Conversations 
    SET PrimaryAgentId = @AgentId, TeamId = @TeamId, AssignedAt = GETDATE()
    WHERE ConversationId = @ConversationId
    
    COMMIT TRANSACTION
END;

-- Procedure: Update Message Status
CREATE PROCEDURE sp_UpdateMessageStatus
    @MessageId BIGINT,
    @Status NVARCHAR(20),
    @UpdatedBy BIGINT
AS
BEGIN
    INSERT INTO MessageStatus (MessageId, Status, UpdatedAt, UpdatedBy)
    VALUES (@MessageId, @Status, GETDATE(), @UpdatedBy)
    
    UPDATE Messages
    SET MessageStatus = @Status,
        DeliveredAt = CASE WHEN @Status = 'delivered' THEN GETDATE() ELSE DeliveredAt END,
        ReadAt = CASE WHEN @Status = 'read' THEN GETDATE() ELSE ReadAt END,
        UpdatedAt = GETDATE()
    WHERE MessageId = @MessageId
END;

-- End of SQL Server Schema
