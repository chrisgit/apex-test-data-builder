// Helper class for dealing with sObjects in Test
@IsTest
public class FakeAnId {
    private static Integer fakeIdAutoNumber = 1;

    // Usage: FakeAnId.forObject(SObjectType), e.g. FakeAnId.forObject(Account.SObjectType)
    public static String forObject(Schema.SObjectType objectType) {
        return forObject(objectType, fakeIdAutoNumber++);
    }

    public static String forObject(Schema.SObjectType objectType, Integer fakeId) {
        return objectType.getDescribe().getKeyPrefix() + String.valueOf(fakeId).leftPad(12, '0');
    }
}
